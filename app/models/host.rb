# The bacula database must be independent from all of our application logic.
# For this reason we have Host which is the application equivalent of a Bacula Client.
#
# A host is being created from our application. When it receives all the configuration
# which is required it gets dispatched to bacula through some configuration files. After
# that, a client with the exact same config is generated by bacula.
class Host < ActiveRecord::Base
  STATUSES = {
    pending: 0,
    configured: 1,
    dispatched: 2,
    deployed: 3,
    updated: 4,
    redispatched: 5,
    for_removal: 6,
    inactive: 7
  }

  has_many :ownerships
  has_many :users, through: :ownerships, inverse_of: :hosts

  belongs_to :client, class_name: :Client, foreign_key: :name, primary_key: :name
  belongs_to :verifier, class_name: :User, foreign_key: :verifier_id, primary_key: :id

  has_many :filesets, dependent: :destroy
  has_many :job_templates, dependent: :destroy
  has_many :schedules, dependent: :destroy

  validates :file_retention, :job_retention,
    :port, :password, presence: true
  validates :port, numericality: true

  validates :fqdn, presence: true, uniqueness: true

  validate :fqdn_format

  scope :not_baculized, -> {
    joins("left join Client on Client.Name = hosts.name").where(Client: { Name: nil })
  }
  scope :unverified, -> { where(verified: false) }

  before_validation :set_retention, :unset_baculized, :sanitize_name

  state_machine :status, initial: :pending do
    STATUSES.each do |status_name, value|
      state status_name, value: value
    end

    after_transition [:dispatched, :redispatched, :configured, :updated] => :deployed do |host|
      host.job_templates.enabled.
        update_all(baculized: true, baculized_at: Time.now, updated_at: Time.now)
    end

    event :add_configuration do
      transition [:pending, :dispatched, :inactive] => :configured
    end

    event :dispatch do
      transition :configured => :dispatched
    end

    event :redispatch do
      transition :updated => :redispatched
    end

    event :set_deployed do
      transition [:dispatched, :redispatched, :configured, :updated] => :deployed
    end

    event :change_deployed_config do
      transition [:deployed, :redispatched, :for_removal] => :updated
    end

    event :mark_for_removal do
      transition [:dispatched, :deployed, :updated, :redispatched] => :for_removal
    end

    event :set_inactive do
      transition [:deployed, :dispatched, :updated, :redispatched] => :inactive
    end

    event :disable do
      transition all => :pending
    end
  end

  # Constructs the final Bacula configuration for the host by appending configs for
  #
  # * Client
  # * Jobs
  # * Schedules
  # * Filesets
  #
  # by calling their `to_bacula_config_array` methods.
  #
  # @return [Array] containing each element's configuration line by line
  def baculize_config
    templates = job_templates.includes(:fileset, :schedule)

    result = [self] + templates.map {|x| [x, x.fileset, x.schedule] }.flatten.compact.uniq
    result.map(&:to_bacula_config_array)
  end

  # Constructs the final Bacula configuration for the host by appending configs for
  #
  # * Client
  # * Jobs
  # * Schedules
  # * Filesets
  #
  # by calling their `to_bacula_config_array` methods.
  #
  # It hides the password.
  #
  # @return [Array] containing each element's configuration line by line
  def baculize_config_no_pass
    baculize_config.join("\n").gsub(/Password = ".*"$/, 'Password = "*************"')
  end

  # Constructs an array where each element is a line for the Client's bacula config
  #
  # @return [Array]
  def to_bacula_config_array
    [
      "Client {",
      "  Name = #{name}",
      "  Address = #{fqdn}",
      "  FDPort = #{port}",
      "  Catalog = #{client_settings[:catalog]}",
      "  Password = \"#{password}\"",
      "  File Retention = #{file_retention} #{file_retention_period_type}",
      "  Job Retention = #{job_retention} #{job_retention_period_type}",
      "  AutoPrune = #{auto_prune_human}",
      "}"
    ]
  end

  # Shows the host's auto_prune setting
  def auto_prune_human
    client_settings[:autoprune]
  end

  # Uploads the host's config to bacula
  # Reloads bacula server
  #
  # It updates the host's status accordingly
  def dispatch_to_bacula
    return false if not needs_dispatch?
    bacula_handler.deploy_config
  end

  # Removes a Host from bacula configuration.
  # Reloads bacula server
  #
  # If all go well it changes the host's status and returns true
  def remove_from_bacula
    return false unless needs_revoke?
    bacula_handler.undeploy_config
  end

  # Restores a host's backup to a preselected location
  #
  # @param fileset_id[Integer] the desired fileset
  # @param location[String] the desired restore location
  # @param restore_point[Datetime] the desired restore_point datetime
  def restore(file_set_id, location, restore_point=nil)
    return false if not restorable?
    job_ids = client.get_job_ids(file_set_id, restore_point)
    file_set_name = FileSet.find(file_set_id).file_set
    bacula_handler.restore(job_ids, file_set_name, location)
  end

  # Runs the given backup job ASAP
  def backup_now(job_name)
    bacula_handler.backup_now(job_name)
  end

  # Disables all jobs and sends the configuration to Bacula
  def disable_jobs_and_update
    job_templates.update_all(enabled: false)
    bacula_handler.deploy_config
  end

  # Determinex weather a host:
  #
  # * has all it takes to be deployed but
  # * the config is not yet sent to bacula
  #
  # @return [Boolean]
  def needs_dispatch?
    verified? && (can_dispatch? || can_redispatch?)
  end

  # Determines weather a host is marked for removal
  #
  # @return [Boolean]
  def needs_revoke?
    for_removal?
  end

  # Handles the host's job changes by updating the host's status
  def recalculate
    add_configuration || change_deployed_config
  end

  # Fetches an info message concerning the host's deploy status
  def display_message
    if !verified?
      { message: 'Your host needs to be verified by an admin', severity: :alert }
    elsif pending?
      { message: 'client not configured yet', severity: :alert }
    elsif configured? || dispatched?
      { message: 'client not deployed to Bacula', severity: :alert }
    elsif updated? || redispatched?
      { message: 'client configuration changed, deploy needed', severity: :alert }
    elsif for_removal?
      { message: 'pending client configuration withdraw', severity: :error }
    elsif inactive?
      { message: 'client disabled', severity: :alert }
    end
  end

  # Determines if a host can issue a restore job.
  #
  # @returns [Boolean] true if the host's client can issue a restore job
  def restorable?
    client.present? && client.is_backed_up?
  end

  # @return [User] the first of the host's users
  def first_user
    users.order('ownerships.created_at asc').first
  end

  # Marks the host as verified and sets the relevant metadata
  #
  # @param admin_verifier[Integer] the verifier's id
  def verify(admin_verifier)
    self.verified = true
    self.verifier_id = admin_verifier
    self.verified_at = Time.now
    save
  end

  # Determines if a host can be disabled or not.
  # Equivalent to is_deployed
  #
  # @return [Boolean]
  def can_be_disabled?
    dispatched? || deployed? || updated? || redispatched?
  end

  private

  # automatic setters

  def sanitize_name
    self.name = fqdn
  end

  # Sets the file and job retention according to the global settings
  def set_retention
    self.file_retention = client_settings[:file_retention]
    self.file_retention_period_type = client_settings[:file_retention_period_type]
    self.job_retention = client_settings[:job_retention]
    self.job_retention_period_type = client_settings[:job_retention_period_type]
  end

  def unset_baculized
    self.baculized = false if new_record?
    true
  end

  # validation

  def fqdn_format
    regex = /(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+[a-zA-Z]{2,63}$)/
    unless fqdn =~ regex
      self.errors.add(:fqdn)
    end
  end

  # Proxy object for handling bacula directives
  def bacula_handler
    BaculaHandler.new(self)
  end

  # Fetches and memoizes the general configuration settings for Clients
  #
  # @see ConfigurationSetting.current_client_settings
  # @return [Hash] containing the settings
  def client_settings
    @client_settings ||= ConfigurationSetting.current_client_settings
  end
end

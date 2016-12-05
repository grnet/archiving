# The bacula database must be independent from all of our application logic.
# For this reason we have Host which is the application equivalent of a Bacula Client.
#
# A host is being created from our application. When it receives all the configuration
# which is required it gets dispatched to bacula through some configuration files. After
# that, a client with the exact same config is generated by bacula.
class Host < ActiveRecord::Base
  establish_connection ARCHIVING_CONF

  include Configuration::Host

  STATUSES = {
    pending: 0,
    configured: 1,
    dispatched: 2,
    deployed: 3,
    updated: 4,
    redispatched: 5,
    for_removal: 6,
    inactive: 7,
    blocked: 8
  }

  # The default file daemon port
  DEFAULT_PORT = 9102

  enum origin: { institutional: 0, vima: 1, okeanos: 2 }
  serialize :email_recipients, JSON

  has_many :simple_configurations
  has_many :ownerships
  has_many :users, through: :ownerships, inverse_of: :hosts
  has_many :invitations

  belongs_to :client, class_name: :Client, foreign_key: :name, primary_key: :name
  belongs_to :verifier, class_name: :User, foreign_key: :verifier_id, primary_key: :id

  has_many :filesets, dependent: :destroy
  has_many :job_templates, dependent: :destroy
  has_many :schedules, dependent: :destroy

  validates :file_retention, :job_retention,
    :port, :password, presence: true
  validates :port, :quota, numericality: { greater_than: 0 }

  validates :fqdn, presence: true, uniqueness: true

  validate :fqdn_format

  validate :valid_recipients

  scope :not_baculized, -> {
    joins("left join #{Client.table_name} on #{Client.table_name}.Name = hosts.name").
      where(Client.table_name => { Name: nil })
  }

  scope :in_bacula, -> {
    where(
      status: STATUSES.select { |k,_|
        [:deployed, :updated, :redispatched, :for_removal].include? k
      }.values
    )
  }

  scope :unverified, -> { where(verified: false) }

  before_validation :set_retention, :unset_baculized, :sanitize_name,
    :sanitize_email_recipients, :set_password, :set_port, :set_quota

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
      transition [:configured, :deployed, :dispatched, :updated, :redispatched] => :inactive
    end

    event :disable do
      transition all => :pending
    end

    event :block do
      transition all - [:blocked] => :blocked
    end

    event :unblock do
      transition :blocked => :pending
    end
  end

  # API serializer
  # Override `as_json` method to personalize for API use.
  def as_json(opts={})
    if for_api = opts.delete(:for_api)
      api_json
    else
      super(opts)
    end
  end

  # Determines if a host has enabled jobs in order to be dispatched to Bacula
  #
  # @return [Boolean]
  def bacula_ready?
    job_templates.enabled.any?
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
  #
  # @param force[Boolean] forces removal
  def remove_from_bacula(force=false)
    return false if not (force || needs_revoke?)
    bacula_handler.undeploy_config
  end

  # Determines if a host needs a simple config
  #
  # @return [Boolean]
  def needs_simple_config?
    job_templates.none? && simple_configurations.none?
  end

  # Restores a host's backup to a preselected location
  #
  # @param fileset_id[Integer] the desired fileset
  # @param location[String] the desired restore location
  # @param restore_point[Datetime] the desired restore_point datetime
  # @param restore_client[String]] the desired restore client
  def restore(file_set_id, location, restore_point=nil, restore_client=nil)
    return false if not restorable?
    job_ids = client.get_job_ids(file_set_id, restore_point)
    file_set_name = FileSet.find(file_set_id).file_set
    bacula_handler.restore(job_ids, file_set_name, restore_point, location, restore_client)
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

  # Disables all jobs if needed and then locks the host
  def disable_jobs_and_lock
    return false if can_set_inactive? && !disable_jobs_and_update
    block
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
    elsif blocked?
      { message: 'client disabled by admin.', severity: :error }
    end
  end

  # Determines if a host can issue a restore job.
  #
  # @return [Boolean] true if the host's client can issue a restore job
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
    recipients = users.pluck(:email)
    if save
      UserMailer.notify_for_verification(recipients, self).deliver if recipients.any?
      return true
    end
    false
  end

  # Determines if a host can be disabled or not.
  # Equivalent to is_deployed
  #
  # @return [Boolean]
  def can_be_disabled?
    dispatched? || deployed? || updated? || redispatched?
  end

  # Determines if a host is inserted manually from the user or
  #  provided as an option from a list by the system via a third party
  #  like ViMa or Okeanos
  #
  #  @return [Boolean]
  def manually_inserted?
    institutional?
  end

  # Resets the hosts token
  #
  # @return [Boolean]
  def recalculate_token
    self.password = token
    save
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

  def sanitize_email_recipients
    self.email_recipients.reject!(&:blank?)
  end

  def set_password
    return true if persisted?

    self.password = token
  end

  def token
    Digest::SHA256.hexdigest(
      Time.now.to_s + Rails.application.secrets.salt + fqdn.to_s
    )
  end

  def set_port
    return true if persisted?

    self.port = DEFAULT_PORT
  end

  def set_quota
    return true if persisted?

    self.quota = ConfigurationSetting.client_quota
  end

  # validation

  def fqdn_format
    regex = /(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+[a-zA-Z]{2,63}$)/
    unless fqdn =~ regex
      self.errors.add(:fqdn)
    end
  end

  def valid_recipients
    if !email_recipients.all? { |email| email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
      self.errors.add(:email_recipients)
    end
  end

  # Handles the returned attribues for api
  #
  # @return [Hash] of the desired attributes for api use
  def api_json
    {
      id: id,
      name: name,
      uname: client.uname,
      port: port,
      file_retention: "#{file_retention} #{file_retention_period_type}",
      job_retention: "#{job_retention} #{job_retention_period_type}",
      quota: quota,
      last_backup: client.last_job_datetime,
      files: client.files_count,
      space_used: client.backup_jobs_size,
      collaborators: email_recipients,
      backup_jobs: job_templates.enabled.backup.map(&:api_json),
      restorable_filesets: client.file_sets.map(&:api_json)
    }
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

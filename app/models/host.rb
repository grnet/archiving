class Host < ActiveRecord::Base
  establish_connection Baas::settings[:local_db]

  FILE_RETENTION_DAYS = 60
  JOB_RETENTION_DAYS = 180
  CATALOG = 'MyCatalog'
  AUTOPRUNE = 1

  STATUSES = {
    pending: 0,
    configured: 1,
    dispatched: 2,
    deployed: 3,
    updated: 4,
    redispatched: 5,
    for_removal: 6
  }

  belongs_to :client, class_name: :Client, foreign_key: :name, primary_key: :name

  has_many :filesets, dependent: :destroy
  has_many :job_templates, dependent: :destroy
  has_many :schedules, dependent: :destroy

  validates :file_retention, :job_retention,
    :port, :password, presence: true
  validates :port, numericality: true

  validates :fqdn, presence: true, uniqueness: true

  validate :fqdn_format

  scope :not_baculized, -> { where(baculized: false) }

  before_validation :set_retention, :unset_baculized, :sanitize_name

  state_machine :status, initial: :pending do
    STATUSES.each do |status_name, value|
      state status_name, value: value
    end

    event :add_configuration do
      transition [:pending, :dispatched] => :configured
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

    event :disable do
      transition all => :pending
    end
  end

  def baculize_config
    templates = job_templates.enabled.includes(:fileset, :schedule)

    result = [self] + templates.map {|x| [x, x.fileset, x.schedule] }.flatten.compact.uniq
    result.map(&:to_bacula_config_array)
  end

  def to_bacula_config_array
    [
      "Client {",
      "  Name = #{name}",
      "  Address = #{fqdn}",
      "  FDPort = #{port}",
      "  Catalog = #{CATALOG}",
      "  Password = \"#{password}\"",
      "  File Retention = #{file_retention} days",
      "  Job Retention = #{job_retention} days",
      "  AutoPrune = yes",
      "}"
    ]
  end

  def auto_prune_human
    AUTOPRUNE == 1 ? 'yes' : 'no'
  end

  def dispatch_to_bacula
    return false if not needs_dispatch?
    BaculaHandler.new(self).deploy_config
  end

  def needs_dispatch?
    verified? && (can_dispatch? || can_redispatch?)
  end

  def needs_revoke?
    for_removal?
  end

  # Handles the host's job changes by updating the host's status
  def recalculate
    if job_templates(true).enabled.any?
      add_configuration || change_deployed_config
    else
      mark_for_removal || disable
    end
  end

  private

  # automatic setters

  def sanitize_name
    self.name = fqdn
  end

  def set_retention
    self.file_retention = FILE_RETENTION_DAYS
    self.job_retention = JOB_RETENTION_DAYS
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
end

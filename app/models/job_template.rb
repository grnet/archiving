class JobTemplate < ActiveRecord::Base
  establish_connection Baas::settings[:local_db]

  enum job_type: { backup: 0, restore: 1, verify: 2, admin: 3 }

  belongs_to :host
  belongs_to :fileset
  belongs_to :schedule

  validates :name, :fileset_id,  presence: true
  validates :schedule_id, presence: true, unless: :restore?

  before_save :set_job_type

  scope :enabled, -> { where(enabled: true) }

  # configurable
  DEFAULT_OPTIONS = {
    storage: :File,
    pool: :Default,
    messages: :Standard,
    priority: 10,
    :'Write Bootstrap' => '"/var/lib/bacula/%c.bsr"'
  }

  def to_bacula_config_array
    ['Job {'] +
      DEFAULT_OPTIONS.map { |k,v| "  #{k.capitalize} = #{v}" } +
      options_array.map { |x| "  #{x}" } +
      ['}']
  end

  def priority
    DEFAULT_OPTIONS[:priority]
  end

  def enabled_human
    enabled? ? 'yes' : 'no'
  end

  def schedule_human
    schedule.present? ? schedule.name : '-'
  end

  def save_and_create_restore_job
    if save_status = save
      restore_job = JobTemplate.new(host: host, job_type: :restore,
                                    fileset: fileset, name: 'Restore_' + name)
      restore_job.save
    end
    save_status
  end

  private

  # Sets the default job_type as backup
  def set_job_type
    self.job_type = :backup if job_type.nil?
  end

  def options_array
    result = restore? ? ['Where = "/tmp/bacula-restores"'] : []
    result +=  [
      "Name = \"#{name}\"",
      "FileSet = \"#{fileset.name}\"",
      "Client = \"#{host.name}\"",
      "Type = \"#{job_type.capitalize}\"",
      "Schedule = \"#{schedule.name}\""
    ]
  end
end

class JobTemplate < ActiveRecord::Base
  establish_connection Baas::settings[:local_db]

  enum job_type: { backup: 0, restore: 1, verify: 2, admin: 3 }

  belongs_to :host
  belongs_to :fileset
  belongs_to :schedule

  validates :name, :schedule_id, :fileset_id,  presence: true

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

  private

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

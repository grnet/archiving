class JobTemplate < ActiveRecord::Base
  establish_connection Baas::settings[:local_db]

  enum job_type: { backup: 0, restore: 1, verify: 2, admin: 3 }

  belongs_to :host
  belongs_to :fileset
  belongs_to :schedule

  validates :name, :fileset_id,  presence: true
  validates :schedule_id, presence: true, unless: :restore?
  validates :name, uniqueness: { scope: :host }
  validates_with NameValidator

  before_save :set_job_type
  after_save :notify_host

  scope :enabled, -> { where(enabled: true) }

  def to_bacula_config_array
    ['Job {'] +
      options_array.map { |x| "  #{x}" } +
      job_settings.map { |k,v| "  #{k.capitalize} = #{v}" } +
      ['}']
  end

  def priority
    job_settings[:priority]
  end

  def enabled_human
    enabled? ? 'yes' : 'no'
  end

  def schedule_human
    schedule.present? ? schedule.name : '-'
  end

  def name_for_config
    "#{host.name} #{name}"
  end

  # Sends a hot backup request to Bacula via BaculaHandler
  def backup_now
    return false if not (enabled? && baculized? && backup?)
    host.backup_now(name)
  end

  private

  def name_format
    unless name =~ /^[a-zA-Z0-1\.-_ ]+$/
      self.errors.add(:name, :format)
    end
  end

  def notify_host
    host.recalculate
  end

  # Sets the default job_type as backup
  def set_job_type
    self.job_type = :backup if job_type.nil?
  end

  def options_array
    result = [
      "Name = \"#{name_for_config}\"",
      "FileSet = \"#{fileset.name_for_config}\"",
      "Client = \"#{host.name}\"",
      "Type = \"#{job_type.capitalize}\"",
      "Schedule = \"#{schedule.name_for_config}\""
    ]

    if client_before_run_file.present?
      result += ["Client Run Before Job = \"#{client_before_run_file}\""]
    end
    if client_after_run_file.present?
      result += ["Client Run After Job = \"#{client_after_run_file}\""]
    end

    result
  end

  # Fetches and memoizes the general configuration settings for Jobs
  #
  # @see ConfigurationSetting.current_job_settings
  # @return [Hash] containing the settings
  def job_settings
    @job_settings ||= ConfigurationSetting.current_job_settings
  end
end

# JobTemplate class is a helper class that enables us to configure Bacula job
# configurations, without messing with Bacula's native models (Job).
# It has a unique:
#
# * host
# * fileset
# * schedule
class JobTemplate < ActiveRecord::Base
  establish_connection ARCHIVING_CONF

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

  # Constructs an array where each element is a line for the Job's bacula config
  #
  # @return [Array]
  def to_bacula_config_array
    ['Job {'] +
      options_array.map { |x| "  #{x}" } +
      job_settings.map { |k,v| "  #{k.capitalize} = #{v}" } +
      ['}']
  end

  # Fetches the Job's priority
  def priority
    job_settings[:priority]
  end

  # Helper method for the job template's enabled status
  def enabled_human
    enabled? ? 'yes' : 'no'
  end

  # Helper method for the job template's schedule name
  #
  # @return [String] The schedule's name or nothing
  def schedule_human
    schedule.present? ? schedule.name : '-'
  end

  # Generates a name that will be used for the configuration file.
  # It is the name that will be sent to Bacula through the configuration
  # files.
  #
  # @return [String]
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
      "Enabled = #{enabled_human}",
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
    messages = host.email_recipients.any? ? "message_#{host.name}" : :Standard
    @job_settings ||= ConfigurationSetting.current_job_settings.merge(messages: messages)
  end
end

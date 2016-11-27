# Schedule model is the application representation of Bacula's Schedule.
# It has references to a host and multiple schedule run in order to provide
# the desired Bacula configuration
class Schedule < ActiveRecord::Base
  establish_connection ARCHIVING_CONF

  has_many :schedule_runs

  belongs_to :host
  has_many :job_templates

  validates :name, presence: true
  validates :name, uniqueness: { scope: :host }
  validates_with NameValidator

  accepts_nested_attributes_for :schedule_runs, allow_destroy: true

  # Constructs an array where each element is a line for the Schedule's bacula config
  #
  # @return [Array]
  def to_bacula_config_array
    ['Schedule {'] +
      ["  Name = \"#{name_for_config}\""] +
      schedule_runs.map {|r| "  Run = #{r.schedule_line}" } +
      ['}']
  end

  # Provide a human readable projection of the schedule
  #
  # @return [String]
  def human_readable
    schedule_runs.map(&:human_readable).join("\n")
  end

  # Generates a name that will be used for the configuration file.
  # It is the name that will be sent to Bacula through the configuration
  # files.
  #
  # @return [String]
  def name_for_config
    [host.name, name].join(' ')
  end

  # Returns the hosts that have enabled jobs that use this schedule
  #
  # @return [ActiveRecord::Colletion] the participating hosts
  def participating_hosts
    Host.joins(:job_templates).where(job_templates: { enabled: true, schedule_id: id }).uniq
  end

  # Creates a default schedule resource for a simple config
  def default_resource(day, hour, minute)
    time = [hour, minute].map { |x| x.to_s.rjust(2, '0') }.join(':')
    full_day = "first #{day}"
    diff_days = "second-fifth #{day}"
    inc_days = (SimpleConfiguration::DAYS.values - [day]).join(',')

    self.name = "daily_at_#{time.gsub(':','_')}"
    save!
    self.schedule_runs.create(level: :full, time: time, day: full_day)
    self.schedule_runs.create(level: :differential, time: time, day: diff_days)
    self.schedule_runs.create(level: :incremental , time: time, day: inc_days)

    self
  end
end

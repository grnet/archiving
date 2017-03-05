class SimpleConfiguration
  include ActiveModel::Model

  attr_accessor :included_files, :day, :hour, :minute, :name

  INCLUDED_FILE_OPTIONS =
    %w{/ /bin /boot /etc /home /lib /media /mnt /opt /root /run /sbin /srv /usr /var}

  DAYS = {
      monday: :mon,
      tuesday: :tue,
      wednesday: :wed,
      thursday: :thu,
      friday: :fri,
      saturday: :sat,
      sunday: :sun
  }

  DAY_NAMES = %w{monday tuesday wednesday thursday friday saturday sunday }

  validates_inclusion_of :day, in: DAY_NAMES
  validates :day, :hour, :minute, presence: true
  validates :hour, numericality: { greater_than_or_equal: 0, less_then: 24 }
  validates :minute, numericality: { greater_than_or_equal: 0, less_then: 60 }
  validates_with NameValidator

  # Initializes the configuration's 3 parameters randomnly.
  # Default configurations must be randomized in order to distribute the backup server's
  # load.
  def randomize
    self.day = DAY_NAMES.sample
    self.hour = rand(24)
    self.minute = rand(60)
  end

  # The day abbreviation
  #
  # @return [Symbol]
  def day_short
    DAYS[day.to_sym]
  end

  # Creates a default config, by adding resources for:
  #
  # * schedule
  # * fileset
  # * job
  #
  # Each resource handles its own defaults.
  #
  # @param host[Host] the host that will receive the config
  def create_config(host)
    self.included_files = included_files.keep_if(&:present?).uniq.presence

    time_hex = Digest::MD5.hexdigest(Time.now.to_f.to_s).first(4)

    schedule = host.schedules.new.default_resource(time_hex, day_short, hour, minute)
    fileset = host.filesets.new.default_resource(name, time_hex, files: included_files)
    host.job_templates.new(fileset_id: fileset.id, schedule_id: schedule.id).
      default_resource(name, time_hex)
  end
end

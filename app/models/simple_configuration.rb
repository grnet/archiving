class SimpleConfiguration < ActiveRecord::Base
  establish_connection ARCHIVING_CONF

  attr_accessor :included_files

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

  enum day: { monday: 0, tuesday: 1, wednesday: 2, thursday: 3, friday: 4, saturday: 5, sunday: 6 }

  belongs_to :host

  validates :host, :day, :hour, :minute, presence: true
  validates :hour, numericality: { greater_than_or_equal: 0, less_then: 24 }
  validates :minute, numericality: { greater_than_or_equal: 0, less_then: 60 }
  validates_with NameValidator

  before_save :sanitize_included_files

  # Initializes the configuration's 3 parameters randomnly.
  # Default configurations must be randomized in order to distribute the backup server's
  # load.
  def randomize
    self.day = SimpleConfiguration.days.keys.sample
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
  def create_config
    time_hex = Digest::MD5.hexdigest(Time.now.to_f.to_s).first(4)

    schedule = host.schedules.new.default_resource(time_hex, day_short, hour, minute)
    fileset = host.filesets.new.default_resource(name, time_hex, files: included_files)
    host.job_templates.new(fileset_id: fileset.id, schedule_id: schedule.id).
      default_resource(name, time_hex)
  end

  private

  def sanitize_included_files
    self.included_files = included_files.keep_if(&:present?).uniq.presence
  end
end

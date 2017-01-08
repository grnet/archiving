# ScheduleRun is a helper class that modelizes the run directives of a schedule
# resource.
#
# It can have 3 levels:
#
# * full
# * differential
# * incremental
#
# Each ScheduleRun instance holds info about the execution time of the schedule:
#
# * month specification is optional and is described by:
#   - month: full name (eg april) | month name three first letters (eg jul)
#   - month_range: month-month
#   - monthly: 'monthly'
# * day specification is required and is described by:
#   - week_number (optional): weeks number in full text (eg: third, fourth)
#   - week_range (optional): week_number-week_number
#   - day: first three letters of day (eg: mon, fri)
#   - day_range: day-day
# * time specification is required and is described by:
#   - 24h time (eg: 03:00)
#
# Schedule Run examples:
#
#  Level=Full monthly first mon at 12:21
#  Level=Full first sun at 12:34
#  Level=Differential second-fifth sat at 15:23
#  Level=Incremental  mon-sat at 08:00
class ScheduleRun < ActiveRecord::Base
  establish_connection ARCHIVING_CONF

  attr_accessor :time_wrapper

  enum level: { full: 0, differential: 1, incremental: 2 }

  MONTH_KW = %w{jan feb mar apr may jun jul aug sep oct nov dec january february march
                april may june july august september october november december}

  DAYS = (1..31).to_a
  WDAY_KW = %w{mon tue wed thu fri sat sun}
  WEEK_KW = %w{first second third fourth fifth}

  belongs_to :schedule

  validates :day, :time, :level, presence: true
  validate :correct_chars
  validate :month_valid, if: "month.present?"
  validate :time_valid
  validate :day_valid

  def self.options_for_select
    levels.keys.zip levels.keys
  end

  def time_wrapper
    time.to_time
  end
  # Builds a sane default schedule_run
  #
  # @return [ScheduleRun]
  def default_run
    self.level = :full
    self.day = "first sun"
    self.time = '04:00'
  end

  # Composes the schedule line for the bacula configuration
  #
  # @return [String]
  def schedule_line
    [ level_to_config, pool_to_config, month, day, "at #{time}"].join(" ")
  end

  # Provides a human readable projection of the schedule run
  #
  # @return [String]
  def human_readable
    ["#{level.capitalize} backup", month, day, "at #{time}"].join(' ')
  end

  private

  def correct_chars
    [:month, :day, :time].each do |x|
      if self.send(x) && self.send(x).to_s.gsub(/[0-9a-zA-Z\-:,]/, '').present?
        self.errors.add(x, 'Invalid characters')
      end
    end
  end

  def month_valid
    if !month_format? && !valid_month_range?
      self.errors.add(:month, 'Invalid month')
    end
  end

  def month_format?
    month_regex = "^(#{MONTH_KW.join('|')}|monthly)$"
    month.match(month_regex).present?
  end

  def valid_month_range?
    months = month.split('-')
    return false if months.length != 2
    MONTH_KW.index(months.last) % 12 - MONTH_KW.index(months.first) % 12 > 0
  end

  def time_valid
    if !time.match(/^([01][0-9]|2[0-3]):[0-5][0-9]$/)
      self.errors.add(:time, 'Invalid time')
    end
  end

  def day_valid
    components = day.split(' ')
    if components.length < 1 || components.length > 2
      self.errors.add(:day, 'Invalid day')
      return false
    end

    if !valid_day?(components.last) && !valid_day_range?(components.last) &&
        !valid_day_listing?(components.last)
      self.errors.add(:day, 'Invalid day')
      return false
    end

    if components.length == 2 && !valid_week?(components.first) &&
        !valid_week_range?(components.first)
      self.errors.add(:day, 'Invalid day')
      return false
    end
    true
  end

  def valid_day_listing?(listing)
    listing.split(',').all? { |d| WDAY_KW.include? d }
  end

  def valid_day?(a_day)
    WDAY_KW.include? a_day
  end

  def valid_day_range?(a_range)
    days = a_range.split('-')
    return false if days.length != 2

    WDAY_KW.index(days.last) - WDAY_KW.index(days.first) > 0
  end

  def valid_week?(a_week)
    WEEK_KW.include? a_week
  end

  def valid_week_range?(a_range)
    weeks = a_range.split('-')
    return false if weeks.length != 2

    WEEK_KW.index(weeks.last) - WEEK_KW.index(weeks.first) > 0
  end

  def level_to_config
    "Level=#{level.capitalize}"
  end

  def pool_to_config
    "Pool=#{ConfigurationSetting.current_pool_settings[level.to_sym]}"
  end
end

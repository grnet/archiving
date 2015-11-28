class ScheduleRun < ActiveRecord::Base
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

  # Composes the schedule line for the bacula configuration
  #
  # @return [String]
  def schedule_line
    [ level_to_config, month, day, "at #{time}"].join(" ")
  end

  private

  def correct_chars
    [:month, :day, :time].each do |x|
      if self.send(x) && self.send(x).to_s.gsub(/[0-9a-zA-Z\-:]/, '').present?
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

    if !valid_day?(components.last) && !valid_day_range?(components.last)
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
end
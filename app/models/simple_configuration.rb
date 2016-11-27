class SimpleConfiguration < ActiveRecord::Base
  establish_connection ARCHIVING_CONF

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
end

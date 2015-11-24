class Schedule < ActiveRecord::Base
  has_many :schedule_runs

  belongs_to :host

  validates :name, presence: true
  validates :name, uniqueness: { scope: :host }
  validates_with NameValidator

  accepts_nested_attributes_for :schedule_runs

  def to_bacula_config_array
    ['Schedule {'] +
      ["  Name = \"#{name_for_config}\""] +
      schedule_runs.map {|r| "  Run = #{r.schedule_line}" } +
      ['}']
  end

  def name_for_config
    [host.name, name].join(' ')
  end
end

class Schedule < ActiveRecord::Base
  serialize :runs, JSON

  validates :name, :runs, presence: true

  def to_bacula_config_array
    ['Schedule {'] +
      ["  Name = \"#{name}\""] +
      runs.map {|r| "  Run = #{r}" } +
      ['}']
  end
end

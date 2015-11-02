class Schedule < ActiveRecord::Base
  DEFAULT_RUNS = [
    'Level=Full 1st sun at ',
    'Level=Differential 2nd-5th sun at ',
    'Level=Incremental mon-sat at '
  ]

  attr_accessor :runtime

  serialize :runs, JSON

  belongs_to :host

  validates :name, :runs, presence: true

  before_validation :set_runs, if: Proc.new { |s| s.runtime.present? }

  def to_bacula_config_array
    ['Schedule {'] +
      ["  Name = \"#{name}\""] +
      runs.map {|r| "  Run = #{r}" } +
      ['}']
  end

  private

  def set_runs
    if valid_runtime?
      self.runs = DEFAULT_RUNS.map { |r| r + runtime }
    else
      self.errors.add(:runtime, :not_valid_24h_time)
      false
    end
  end

  def valid_runtime?
    runtime && runtime[/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/]
  end
end

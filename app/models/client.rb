class Client < ActiveRecord::Base
  self.table_name = :Client
  self.primary_key = :ClientId

  alias_attribute :name, :Name
  alias_attribute :uname, :Uname
  alias_attribute :auto_prune, :AutoPrune
  alias_attribute :file_retention, :FileRetention
  alias_attribute :job_retention, :JobRetention

  has_many :jobs, foreign_key: :ClientId

  DAY_SECS = 60 * 60 * 24

  # Helper method. It shows the client's  job retention,
  # (which is expressed in seconds) in days.
  #
  # @return [Integer]
  def job_retention_days
    job_retention / DAY_SECS
  end


  # Helper method. It shows the client's  file retention,
  # (which is expressed in seconds) in days.
  #
  # @return [Integer]
  def file_retention_days
    file_retention / DAY_SECS
  end
end

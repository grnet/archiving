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

  # Helper method for auto_prune
  #
  # @return [String] 'yes' or 'no'
  def auto_prune_human
    auto_prune == 1 ? 'yes' : 'no'
  end

  def last_job_date
    jobs.maximum(:EndTime)
  end

  # Shows the total file size of the jobs that run for a specific client
  #
  # @return [Integer] Size in Bytes
  def backup_jobs_size
    jobs.backup_type.map(&:job_bytes).sum
  end

  # Shows the total files' count for the jobs that run for a specific client
  #
  # @return [Integer] File count
  def files_count
    jobs.map(&:job_files).sum
  end

  # Fetches the client's jobs that are running at the moment
  #
  # @return [Integer]
  def running_jobs
    jobs.running.count
  end
end

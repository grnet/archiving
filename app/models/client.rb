# Bacula Client class.
# All hosts that are getting backed up with Bacula have a Client entry, with
# attributes concerning the Client.
class Client < ActiveRecord::Base
  self.table_name = :Client
  self.primary_key = :ClientId

  alias_attribute :name, :Name
  alias_attribute :uname, :Uname
  alias_attribute :auto_prune, :AutoPrune
  alias_attribute :file_retention, :FileRetention
  alias_attribute :job_retention, :JobRetention

  has_many :jobs, foreign_key: :ClientId
  has_one :host, foreign_key: :name, primary_key: :Name

  scope :for_user, ->(user_id) { joins(host: :users).where(users: { id: user_id }) }

  DAY_SECS = 60 * 60 * 24

  # Fetches the client's job_templates that are already persisted to
  #  Bacula's configuration
  #
  # @return [ActiveRecord::Relation] of `JobTemplate`
  def persisted_jobs
    host.job_templates.where(baculized: true).includes(:fileset, :schedule)
  end

  # Fetches the client's performed jobs in reverse chronological order
  #
  # @return [ActiveRecord::Relation] of `Job`
  def recent_jobs
    jobs.order(EndTime: :desc).includes(:file_set)
  end

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

  # Helper method for displayin the last job's datetime in a nice format.
  def last_job_date_formatted
    if job_time = jobs.backup_type.last.try(:end_time)
      I18n.l(job_time, format: :long)
    end
  end

  # Shows if a client has any backup jobs to Bacule config
  #
  # @return [Boolean]
  def is_backed_up?
    jobs.backup_type.any?
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

  # Displays the bacula config that is generated from the client's
  # host
  #
  # @return [String]
  def bacula_config
    return unless host
    host.baculize_config.join("\n")
  end
end

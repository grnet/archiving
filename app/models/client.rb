# Bacula Client class.
# All hosts that are getting backed up with Bacula have a Client entry, with
# attributes concerning the Client.
class Client < ActiveRecord::Base
  establish_connection BACULA_CONF

  self.table_name = "#{connection_config[:database]}.Client"
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

  delegate :manually_inserted?, :origin, :quota, to: :host, allow_nil: true

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
    jobs.order(SchedTime: :desc).includes(:file_set)
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
    if job_time = last_job_datetime
      I18n.l(job_time, format: :long)
    end
  end

  # Helper method for fetching the last job's datetime
  def last_job_datetime
    jobs.backup_type.terminated.last.try(:end_time)
  end

  # Fetches the first and last job's end times.
  #
  # @return [Array] of datetimes in proper format
  def backup_enabled_datetime_range
    jobs.backup_type.terminated.pluck(:end_time).minmax.map { |x| x.strftime('%Y-%m-%d') }
  end

  # Shows if a client has any backup jobs to Bacule config
  #
  # @return [Boolean]
  def is_backed_up?
    jobs.backup_type.terminated.any?
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

  # Fetches the job ids that will construct the desired restore
  #
  # @param file_set_id[Integer] the fileset
  # @param restore_point[Datetime] the restore point
  #
  # @return [Array] of ids
  def get_job_ids(file_set_id, restore_point)
    job_ids = {}
    backup_jobs = jobs.backup_type.terminated.where(file_set_id: file_set_id)
    backup_jobs = backup_jobs.where('EndTime < ?', restore_point) if restore_point

    job_ids['F'] = backup_jobs.where(level: 'F').pluck(:JobId).last
    return [] if job_ids['F'].nil?
    job_ids['D'] = backup_jobs.where(level: 'D').where("JobId > ?", job_ids['F']).pluck(:JobId).last
    job_ids['I'] = backup_jobs.where(level: 'I').
      where("JobId > ?", job_ids['D'] || job_ids['F'] ).pluck(:JobId)

    job_ids.values.flatten.compact
  end

  # Fetches the bacula filesets that are associated with the client
  def file_sets
    FileSet.joins(:jobs).where(Job: { JobId: job_ids }).uniq
  end
end

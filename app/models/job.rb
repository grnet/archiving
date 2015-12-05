# Bacula Job table.
#
# The Job table contains one record for each Job run by Bacula.
# Thus normally, there will be one per day per machine added to the database.
# Note, the JobId is used to index Job records in the database, and it often is shown to the user
# in the Console program.
# However, care must be taken with its use as it is not unique from database to database.
# For example, the user may have a database for Client data saved on machine Rufus and another
# database for Client data saved on machine Roxie.
# In this case, the two database will each have JobIds that match those in another database.
# For a unique reference to a Job, see Job below.
#
# The Name field of the Job record corresponds to the Name resource record given in the
# Director's configuration file.
# Thus it is a generic name, and it will be normal to find many Jobs (or even all Jobs)
# with the same Name.
#
# The Job field contains a combination of the Name and the schedule time of the Job by the Director.
# Thus for a given Director, even with multiple Catalog databases, the Job will contain a unique
# name that represents the Job.
#
# For a given Storage daemon, the VolSessionId and VolSessionTime form a unique identification
# of the Job.
#
# This will be the case even if multiple Directors are using the same Storage daemon.
#
# The Job Type (or simply Type) can have one of the following values:
class Job < ActiveRecord::Base
  self.table_name = :Job
  self.primary_key = :JobId

  alias_attribute :job_id, :JobId
  alias_attribute :job, :Job
  alias_attribute :name, :Name
  alias_attribute :type, :Type
  alias_attribute :level, :Level
  alias_attribute :client_id, :ClientId
  alias_attribute :job_status, :JobStatus
  alias_attribute :sched_time, :SchedTime
  alias_attribute :start_time, :StartTime
  alias_attribute :end_time, :EndTime
  alias_attribute :real_end_time, :RealEndTime
  alias_attribute :job_t_date, :JobTDate
  alias_attribute :vol_session_id, :VolSessionId
  alias_attribute :vol_session_time, :VolSessionTime
  alias_attribute :job_files, :JobFiles
  alias_attribute :job_bytes, :JobBytes
  alias_attribute :read_bytes, :ReadBytes
  alias_attribute :job_errors, :JobErrors
  alias_attribute :job_missing_files, :JobMissingFiles
  alias_attribute :pool_id, :PoolId
  alias_attribute :file_set_id, :FileSetId
  alias_attribute :prior_job_id, :PriorJobId
  alias_attribute :purged_files, :PurgedFiles
  alias_attribute :has_base, :HasBase
  alias_attribute :has_cache, :HasCache
  alias_attribute :reviewed, :Reviewed
  alias_attribute :comment, :Comment

  belongs_to :pool, foreign_key: :PoolId
  belongs_to :file_set, foreign_key: :FileSetId
  belongs_to :client, foreign_key: :ClientId

  has_many :bacula_files, foreign_key: :JobId
  has_many :base_files, foreign_key: :BaseJobId
  has_many :job_media, foreign_key: :JobId
  has_many :logs, foreign_key: :JobId

  scope :running, -> { where(job_status: 'R') }
  scope :terminated, -> { where(job_status: 'T') }
  scope :backup_type, -> { where(type: 'B') }
  scope :restore_type, -> { where(type: 'R') }

  HUMAN_STATUS = {
      'A' => 'Canceled by user',
      'B' => 'Blocked',
      'C' => 'Created, not yet running',
      'D' => 'Verify found differences',
      'E' => 'Terminated with errors',
      'F' => 'Waiting for Client',
      'M' => 'Waiting for media mount',
      'R' => 'Running',
      'S' => 'Waiting for Storage daemon',
      'T' => 'Completed successfully',
      'a' => 'SD despooling attributes',
      'c' => 'Waiting for client resource',
      'd' => 'Waiting on maximum jobs',
      'e' => 'Non-fatal error',
      'f' => 'Fatal error',
      'i' => 'Doing batch insert file records',
      'j' => 'Waiting for job resource',
      'm' => 'Waiting for new media',
      'p' => 'Waiting on higher priority jobs',
      's' => 'Waiting for storage resource',
      't' => 'Waiting on start time'
  }

  paginates_per 20

  def level_human
    {
      'F' => 'Full',
      'D' => 'Differential',
      'I' => 'Incremental'
    }[level]
  end

  def status_human
    HUMAN_STATUS[job_status]
  end

  def fileset
    file_set.try(:file_set) || '-'
  end

  def start_time_formatted
    if start_time
      I18n.l(start_time, format: :long)
    end
  end

  def end_time_formatted
    if end_time
      I18n.l(end_time, format: :long)
    end
  end
end

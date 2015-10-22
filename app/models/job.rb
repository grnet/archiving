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
  scope :backup_type, -> { where(type: 'B') }
  scope :restore_type, -> { where(type: 'R') }
end

class JobHisto < ActiveRecord::Base
  self.table_name = :JobHisto

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
end

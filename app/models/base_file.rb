# The BaseFiles table contains all the File references for a particular JobId that point
#  to a Base file - i.e. they were previously saved and hence were not saved in the current
#  JobId but in BaseJobId under FileId.
class BaseFile < ActiveRecord::Base
  establish_connection BACULA_CONF

  self.table_name = "#{connection_config[:database]}.BaseFiles"
  self.primary_key = :BaseId

  alias_attribute :id, :BaseId
  alias_attribute :base_job_id, :BaseJobId
  alias_attribute :job_id, :JobId
  alias_attribute :file_id, :FileId
  alias_attribute :file_index, :FileIndex

  belongs_to :base_job, foreign_key: :BaseJobId, class_name: :Job
  belongs_to :job, foreign_key: :JobId
  belongs_to :bacula_file, foreign_key: :FileId
end

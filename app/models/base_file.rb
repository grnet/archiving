# The BaseFiles table contains all the File references for a particular JobId that point
#  to a Base file - i.e. they were previously saved and hence were not saved in the current
#  JobId but in BaseJobId under FileId.
class BaseFile < ActiveRecord::Base
  self.table_name = :BaseFiles
  self.primary_key = :BaseId
end

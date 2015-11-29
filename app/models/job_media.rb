# Bacula JobMedia table.
#
# The JobMedia table contains one entry at the following:
#
# * start of the job,
# * start of each new tape file,
# * start of each new tape,
# * end of the job.
#
#  Since by default, a new tape file is written every 2GB, in general, you will have more
# than 2 JobMedia records per Job.
# The number can be varied by changing the "Maximum File Size" specified in the Device resource.
# This record allows Bacula to efficiently position close to (within 2GB) any given file in a backup.
# For restoring a full Job, these records are not very important, but if you want to retrieve a
# single file that was written near the end of a 100GB backup, the JobMedia records can speed it
# up by orders of magnitude by permitting forward spacing files and blocks rather than reading
# the whole 100GB backup.
class JobMedia < ActiveRecord::Base
  self.table_name = :JobMedia
  self.primary_key = :JobMediaId

  alias_attribute :job_media_id, :JobMediaId
  alias_attribute :job_id, :JobId
  alias_attribute :media_id, :MediaId
  alias_attribute :first_index, :FirstIndex
  alias_attribute :last_index, :LastIndex
  alias_attribute :start_file, :StartFile
  alias_attribute :end_file, :EndFile
  alias_attribute :start_block, :StartBlock
  alias_attribute :end_block, :EndBlock
  alias_attribute :vol_index, :VolIndex

  belongs_to :Job, foreign_key: :JobId
  belongs_to :Media, foreign_key: :MediaId
end

# Bacula Status table.
#
# Status table is a lookup table linking:
#
# * jobs' status codes and
# * status codes' messages
class Status < ActiveRecord::Base
  self.table_name = :Status
  self.primary_key = :JobStatus

  alias_attribute :job_status, :JobStatus
  alias_attribute :job_status_long, :JobStatusLong
  alias_attribute :severity, :Severity
end

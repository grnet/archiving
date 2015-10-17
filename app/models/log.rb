class Log < ActiveRecord::Base
  self.table_name = :Log
  self.primary_key = :LogId

  alias_attribute :log_id, :LogId
  alias_attribute :job_id, :JobId
  alias_attribute :time, :Time
  alias_attribute :log_text, :LogText

  belongs_to :job, foreign_key: :JobId
end

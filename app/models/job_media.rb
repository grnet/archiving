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
end

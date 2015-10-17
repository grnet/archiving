class PathVisibility < ActiveRecord::Base
  self.table_name = :PathVisibility
  self.primary_key = [:JobId, :PathId]

  alias_attribute :path_id, :PathId
  alias_attribute :job_id, :JobId
  alias_attribute :size, :Size
  alias_attribute :files, :Files
end

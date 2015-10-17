class PathHierarchy < ActiveRecord::Base
  self.table_name = :PathHierarchy
  self.primary_key = :PathId

  alias_attribute :path_id, :PathId
  alias_attribute :p_path_id, :PPathId
end

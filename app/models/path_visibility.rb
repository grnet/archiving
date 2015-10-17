class PathVisibility < ActiveRecord::Base
  self.table_name = :PathVisibility
  self.primary_key = [:JobId, :PathId]
end

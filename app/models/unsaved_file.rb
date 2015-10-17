class UnsavedFile < ActiveRecord::Base
  self.table_name = :UnsavedFiles
  self.primary_key = :UnsavedId
end

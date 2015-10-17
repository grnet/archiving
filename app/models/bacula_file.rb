class BaculaFile < ActiveRecord::Base
  self.table_name = :File
  self.primary_key = :FileId
end

class CdImage < ActiveRecord::Base
  self.table_name = :CDImages
  self.primary_key = :MediaId
end

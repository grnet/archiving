class Filename < ActiveRecord::Base
  self.table_name = :Filename
  self.primary_key = :FilenameId

  alias_attribute :filename_id, :FilenameId
  alias_attribute :name, :Name
end

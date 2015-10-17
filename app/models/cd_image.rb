class CdImage < ActiveRecord::Base
  self.table_name = :CDImages
  self.primary_key = :MediaId

  alias_attribute :last_burn, :LastBurn
end

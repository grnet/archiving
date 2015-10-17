class Storage < ActiveRecord::Base
  self.table_name = :Storage
  self.primary_key = :StorageId

  alias_attribute :storage_id, :StorageId
  alias_attribute :name, :Name
  alias_attribute :auto_changer, :AutoChanger
end

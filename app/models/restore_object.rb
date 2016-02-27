class RestoreObject < ActiveRecord::Base
  establish_connection BACULA_CONF

  self.table_name = "#{connection_config[:database]}.RestoreObject"
  self.primary_key = :RestoreObjectId

  alias_attribute :restore_object_id, :RestoreObjectId
  alias_attribute :object_name, :ObjectName
  alias_attribute :restore_object, :RestoreObject
  alias_attribute :plugin_name, :PluginName
  alias_attribute :object_length, :ObjectLength
  alias_attribute :object_full_length, :ObjectFullLength
  alias_attribute :object_index, :ObjectIndex
  alias_attribute :object_type, :ObjectType
  alias_attribute :file_index, :FileIndex
  alias_attribute :job_id, :JobId
  alias_attribute :object_compression, :ObjectCompression
end

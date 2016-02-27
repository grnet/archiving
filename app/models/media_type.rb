class MediaType < ActiveRecord::Base
  establish_connection BACULA_CONF

  self.table_name = "#{connection_config[:database]}.MediaType"
  self.primary_key = :MediaTypeId

  alias_attribute :media_type_id, :MediaTypeId
  alias_attribute :media_type, :MediaType
  alias_attribute :read_only, :ReadOnly
end

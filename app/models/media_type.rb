class MediaType < ActiveRecord::Base
  self.table_name = :MediaType
  self.primary_key = :MediaTypeId

  alias_attribute :media_type_id, :MediaTypeId
  alias_attribute :media_type, :MediaType
  alias_attribute :read_only, :ReadOnly
end

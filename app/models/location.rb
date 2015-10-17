class Location < ActiveRecord::Base
  self.table_name = :Location
  self.primary_key = :LocationId

  alias_attribute :location_id, :LocationId
  alias_attribute :location, :Location
  alias_attribute :cost, :Cost
  alias_attribute :enabled, :Enabled
end

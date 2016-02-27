# Bacula Location table.
#
# The Location table defines where a Volume is physically.
class Location < ActiveRecord::Base
  establish_connection BACULA_CONF

  self.table_name = "#{connection_config[:database]}.Location"
  self.primary_key = :LocationId

  alias_attribute :location_id, :LocationId
  alias_attribute :location, :Location
  alias_attribute :cost, :Cost
  alias_attribute :enabled, :Enabled

  has_many :media, foreign_key: :LocationId
  has_many :location_logs, foreign_key: :LocationId
end

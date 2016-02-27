# Bacula LocationLog table
class LocationLog < ActiveRecord::Base
  establish_connection BACULA_CONF

  self.table_name = "#{connection_config[:database]}.LocationLog"
  self.primary_key = :LocLogId

  alias_attribute :loc_log_id, :LocLogId
  alias_attribute :date, :Date
  alias_attribute :comment, :Comment
  alias_attribute :media_id, :MediaId
  alias_attribute :location_id, :LocationId
  alias_attribute :new_vol_status, :NewVolStatus
  alias_attribute :new_enabled, :NewEnabled

  belongs_to :media, foreign_key: :MediaId
  belongs_to :location, foreign_key: :LocationId
end

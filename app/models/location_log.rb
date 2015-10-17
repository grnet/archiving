class LocationLog < ActiveRecord::Base
  self.table_name = :LocationLog
  self.primary_key = :LocLogId

  alias_attribute :loc_log_id, :LocLogId
  alias_attribute :date, :Date
  alias_attribute :comment, :Comment
  alias_attribute :media_id, :MediaId
  alias_attribute :location_id, :LocationId
  alias_attribute :new_vol_status, :NewVolStatus
  alias_attribute :new_enabled, :NewEnabled
end

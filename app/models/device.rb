class Device < ActiveRecord::Base
  self.table_name = :Device
  self.primary_key = :DeviceId

  alias_attribute :device_id, :DeviceId
  alias_attribute :name, :Name
  alias_attribute :media_type_id, :MediaTypeId
  alias_attribute :storage_id, :StorageId
  alias_attribute :dev_mounts, :DevMounts
  alias_attribute :dev_read_bytes, :DevReadBytes
  alias_attribute :dev_write_bytes, :DevWriteBytes
  alias_attribute :dev_read_bytes_since_cleaning, :DevReadBytesSinceCleaning
  alias_attribute :dev_write_bytes_since_cleaning, :DevWriteBytesSinceCleaning
  alias_attribute :dev_read_time, :DevReadTime
  alias_attribute :dev_write_time, :DevWriteTime
  alias_attribute :dev_read_time_since_cleaning, :DevReadTimeSinceCleaning
  alias_attribute :dev_write_time_since_cleaning, :DevWriteTimeSinceCleaning
  alias_attribute :cleaning_date, :CleaningDate
  alias_attribute :cleaning_period, :CleaningPeriod

  has_many :media, foreign_key: :DeviceId
end

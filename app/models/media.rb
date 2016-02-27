# Bacula Media table (Volume)
#
# Media table contains one entry for each volume, that is each tape, cassette (8mm, DLT, DAT, ...),
# or file on which information is or was backed up.
# There is one Volume record created for each of the NumVols specified in the
# Pool resource record.
class Media < ActiveRecord::Base
  establish_connection BACULA_CONF

  self.table_name = "#{connection_config[:database]}.Media"
  self.primary_key = :MediaId

  alias_attribute :media_id, :MediaId
  alias_attribute :volume_name, :VolumeName
  alias_attribute :slot, :Slot
  alias_attribute :pool_id, :PoolId
  alias_attribute :media_type, :MediaType
  alias_attribute :media_type_id, :MediaTypeId
  alias_attribute :label_type, :LabelType
  alias_attribute :first_written, :FirstWritten
  alias_attribute :last_written, :LastWritten
  alias_attribute :label_date, :LabelDate
  alias_attribute :vol_jobs, :VolJobs
  alias_attribute :vol_files, :VolFiles
  alias_attribute :vol_blocks, :VolBlocks
  alias_attribute :vol_mounts, :VolMounts
  alias_attribute :vol_bytes, :VolBytes
  alias_attribute :vol_parts, :VolParts
  alias_attribute :vol_errors, :VolErrors
  alias_attribute :vol_writes, :VolWrites
  alias_attribute :vol_capacity_bytes, :VolCapacityBytes
  alias_attribute :vol_status, :VolStatus
  alias_attribute :enabled, :Enabled
  alias_attribute :recycle, :Recycle
  alias_attribute :action_on_purge, :ActionOnPurge
  alias_attribute :vol_retention, :VolRetention
  alias_attribute :vol_use_duration, :VolUseDuration
  alias_attribute :max_vol_jobs, :MaxVolJobs
  alias_attribute :max_vol_files, :MaxVolFiles
  alias_attribute :max_vol_bytes, :MaxVolBytes
  alias_attribute :in_changer, :InChanger
  alias_attribute :storage_id, :StorageId
  alias_attribute :device_id, :DeviceId
  alias_attribute :media_addressing, :MediaAddressing
  alias_attribute :vol_read_time, :VolReadTime
  alias_attribute :vol_write_time, :VolWriteTime
  alias_attribute :end_file, :EndFile
  alias_attribute :end_block, :EndBlock
  alias_attribute :location_id, :LocationId
  alias_attribute :recycle_count, :RecycleCount
  alias_attribute :initial_write, :InitialWrite
  alias_attribute :scratch_pool_id, :ScratchPoolId
  alias_attribute :recycle_pool_id, :RecyclePoolId
  alias_attribute :comment, :Comment

  belongs_to :pool, foreign_key: :PoolId
  belongs_to :storage, foreign_key: :StorageId
  belongs_to :device, foreign_key: :DeviceId
  belongs_to :location, foreign_key: :LocationId

  has_many :job_media, foreign_key: :MediaId
  has_many :location_logs, foreign_key: :MediaId
end

class Pool < ActiveRecord::Base
  self.table_name = :Pool
  self.primary_key = :PoolId

  alias_attribute :pool_id, :PoolId
  alias_attribute :name, :Name
  alias_attribute :num_vols, :NumVols
  alias_attribute :max_vols, :MaxVols
  alias_attribute :use_once, :UseOnce
  alias_attribute :use_catalog, :UseCatalog
  alias_attribute :accept_any_volume, :AcceptAnyVolume
  alias_attribute :vol_retention, :VolRetention
  alias_attribute :vol_use_duration, :VolUseDuration
  alias_attribute :max_vol_jobs, :MaxVolJobs
  alias_attribute :max_vol_files, :MaxVolFiles
  alias_attribute :max_vol_bytes, :MaxVolBytes
  alias_attribute :auto_prune, :AutoPrune
  alias_attribute :recycle, :Recycle
  alias_attribute :action_on_purge, :ActionOnPurge
  alias_attribute :pool_type, :PoolType
  alias_attribute :label_type, :LabelType
  alias_attribute :label_format, :LabelFormat
  alias_attribute :enabled, :Enabled
  alias_attribute :scratch_pool_id, :ScratchPoolId
  alias_attribute :recycle_pool_id, :RecyclePoolId
  alias_attribute :next_pool_id, :NextPoolId
  alias_attribute :migration_high_bytes, :MigrationHighBytes
  alias_attribute :migration_low_bytes, :MigrationLowBytes
  alias_attribute :migration_time, :MigrationTime

  has_many :jobs, foreign_key: :PoolId
  has_many :media, foreign_key: :PoolId
end

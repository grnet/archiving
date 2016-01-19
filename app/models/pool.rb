# Bacula Pool
#
# The Pool table contains one entry for each media pool controlled by Bacula in
# this database. One media record exists for each of the NumVols contained in the Pool.
# The PoolType is a Bacula defined keyword.
# The MediaType is defined by the administrator, and corresponds to the MediaType
# specified in the Director's Storage definition record.
# The CurrentVol is the sequence number of the Media record for the current volume.
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

  validates_confirmation_of :name

  BOOLEAN_OPTIONS = [['no', 0], ['yes', 1]]
  POOL_OPTIONS = [:name, :vol_retention, :use_once, :auto_prune, :recycle,
                  :max_vols, :max_vol_jobs, :max_vol_files, :max_vol_bytes, :label_format]

  # @return [Array] of all the available pools by name
  def self.available_options
    pluck(:Name)
  end

  # Persists the unpersisted record to bacula via its bacula handler
  #
  # @return [Boolean] according to the persist status
  def submit_to_bacula
    return false if !valid? || !ready_for_bacula?
    sanitize_names
    bacula_handler.deploy_config
  end

  # Constructs an array where each element is a line for the Job's bacula config
  #
  # @return [Array]
  def to_bacula_config_array
    ['Pool {'] +
      options_array.map { |x| "  #{x}" } +
      ['}']
  end

  # Human readable volume retention
  #
  # @return [String] the volume's retention in days
  def vol_retention_human
    "#{vol_retention_days} days"
  end

  # volume retention in days
  def vol_retention_days
    vol_retention / 1.day.to_i
  end

  private

  # proxy object for bacula pool handling
  def bacula_handler
    BaculaPoolHandler.new(self)
  end

  # pool names and label formats should only contain alphanumeric values
  def sanitize_names
    self.name = name.gsub(/[^a-zA-Z0-9]/, '_')
    self.label_format = label_format.gsub(/[^a-zA-Z0-9]/, '_')
  end

  def options_array
    boolean_options = Hash[BOOLEAN_OPTIONS].invert
    [
      "Name = \"#{name}\"",
      "Volume Retention = #{vol_retention_human}",
      "Use Volume Once = #{boolean_options[use_once.to_i]}",
      "AutoPrune = #{boolean_options[auto_prune.to_i]}",
      "Recycle = #{boolean_options[recycle.to_i]}",
      "Maximum Volumes = #{max_vols}",
      "Maximum Volume Jobs = #{max_vol_jobs}",
      "Maximum Volume Files = #{max_vol_files}",
      "Maximum Volume Bytes = #{max_vol_bytes}G",
      "Label Format = \"#{label_format}\"",
      "Pool Type = Backup"
    ]
  end

  def ready_for_bacula?
    POOL_OPTIONS.all? { |attr| self.send(attr).present? }
  end
end

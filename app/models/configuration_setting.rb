# ConfigurationSetting class describes a model that keeps the current Bacula
# configuration.
#
# It has some hard coded settings as defaults.
# Archiving's admins can enter new settings concerning:
#
# * jobs
# * clients
#
# and override the default ones.
#
# ConfigurationSetting is supposed to have only one record in persisted in the database
# which will hold the altered configuration as a patch to the defaults.
# Admins can reset this change at any time.
class ConfigurationSetting < ActiveRecord::Base
  establish_connection ARCHIVING_CONF
  extend ActionView::Helpers::NumberHelper

  MEGA_BYTES = 1024 * 1024
  GIGA_BYTES = MEGA_BYTES * 1024
  TERA_BYTES = GIGA_BYTES * 1024

  serialize :job, JSON
  serialize :client, JSON
  serialize :pool, JSON

  JOB = {
    storage: :File,
    pool: Archiving.settings[:default_pool],
    messages: :Standard,
    priority: 10,
    :'Write Bootstrap' => '"/var/lib/bacula/%c.bsr"',
    :'Spool Data' => 'yes'
  }

  CLIENT = {
    catalog: 'MyCatalog',
    file_retention: 60,
    file_retention_period_type: 'days',
    job_retention: 180,
    job_retention_period_type: 'days',
    autoprune: 'yes',
    quota: Archiving.settings[:client_quota]
  }

  POOL = {
    full: Archiving.settings[:default_pool],
    differential: Archiving.settings[:default_pool],
    incremental: Archiving.settings[:default_pool]
  }


  RETENTION_PERIODS = %w{seconds minutes hours days weeks months quarters years}
  AUTOPRUNE_OPTIONS = ['yes', 'no']

  # Fetches the current configuration for jobs.
  #
  # The current configuration is the last submitted record, patched to the default
  # settings.
  # If there is no record, the default settings are returned
  #
  # @return [Hash] with settings
  def self.current_job_settings
    (last || new).job.symbolize_keys.reverse_merge(JOB.dup)
  end

  # Fetches the current configuration for clients.
  #
  # The current configuration is the last submitted record, patched to the default
  # settings.
  # If there is no record, the default settings are returned
  #
  # @return [Hash] with settings
  def self.current_client_settings
    (last || new).client.symbolize_keys.reverse_merge(CLIENT.dup)
  end

  # Fetches the current configuration for pools.
  #
  # The current configuration is the last submitted record, patched to the default
  # settings.
  # If there is no record, the default settings are returned
  #
  # @return [Hash] with settings
  def self.current_pool_settings
    (last || new).pool.symbolize_keys.reverse_merge(POOL.dup)
  end

  # Fetches the provided client size quota
  #
  # @return [Integer] bytes space quota per client
  def self.client_quota
    current_client_settings[:quota]
  end

  # Fetches the record's configuration for jobs.
  #
  # The configuration is the record's configuration patched to the default
  # settings.
  #
  # @return [Hash] with settings
  def current_job_settings
    job.symbolize_keys.reverse_merge(JOB.dup)
  end

  # Fetches the record's configuration for clients.
  #
  # The configuration is the record's configuration patched to the default
  # settings.
  #
  # @return [Hash] with settings
  def current_client_settings
    client.symbolize_keys.reverse_merge(CLIENT.dup)
  end

  def self.current_client_settings_human
    current_client_settings.merge(quota: number_to_human_size(current_client_settings[:quota]))
  end

  # Fetches the record's configuration for pools.
  #
  # The configuration is the record's configuration patched to the default
  # settings.
  #
  # @return [Hash] with settings
  def current_pool_settings
    pool.symbolize_keys.reverse_merge(POOL.dup)
  end
end

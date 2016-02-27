# Bacula Storage table
#
# The Storage table contains one entry for each Storage used.
class Storage < ActiveRecord::Base
  establish_connection BACULA_CONF

  self.table_name = "#{connection_config[:database]}.Storage"
  self.primary_key = :StorageId

  alias_attribute :storage_id, :StorageId
  alias_attribute :name, :Name
  alias_attribute :auto_changer, :AutoChanger

  has_many :media, foreign_key: :StorageId

  def self.available_options
    pluck(:Name)
  end
end

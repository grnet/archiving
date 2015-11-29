# Bacula Storage table
#
# The Storage table contains one entry for each Storage used.
class Storage < ActiveRecord::Base
  self.table_name = :Storage
  self.primary_key = :StorageId

  alias_attribute :storage_id, :StorageId
  alias_attribute :name, :Name
  alias_attribute :auto_changer, :AutoChanger

  has_many :media, foreign_key: :StorageId

  def self.available_options
    pluck(:Name)
  end
end

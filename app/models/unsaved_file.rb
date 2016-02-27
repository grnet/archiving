# Bacula UnsavedFile table
class UnsavedFile < ActiveRecord::Base
  establish_connection BACULA_CONF

  self.table_name = "#{connection_config[:database]}.UnsavedFiles"
  self.primary_key = :UnsavedId

  alias_attribute :unsaved_id, :UnsavedId
  alias_attribute :job_id, :JobId
  alias_attribute :path_id, :PathId
  alias_attribute :filename_id, :FilenameId
end

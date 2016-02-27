# Bacula Path table.
#
# The Path table contains shown above the path or directory names of all directories on
# the system or systems.
# As with the filename, only one copy of each directory name is kept regardless of how
# many machines or drives have the same directory.
# These path names should be stored in Unix path name format.
class Path < ActiveRecord::Base
  establish_connection BACULA_CONF

  self.table_name = "#{connection_config[:database]}.Path"
  self.primary_key = :PathId

  alias_attribute :path_id, :PathId
  alias_attribute :path, :Path

  has_many :bacula_files, foreign_key: :PathId
end

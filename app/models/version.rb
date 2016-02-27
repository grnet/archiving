# Bacula Version table
#
# The Version table defines the Bacula database version number.
# Bacula checks this number before reading the database to ensure that it is
# compatible with the Bacula binary file.
class Version < ActiveRecord::Base
  establish_connection BACULA_CONF

  self.table_name = "#{connection_config[:database]}.Version"

  alias_attribute :version_id, :VersionId
end

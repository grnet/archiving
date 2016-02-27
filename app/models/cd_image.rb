class CdImage < ActiveRecord::Base
  establish_connection BACULA_CONF

  self.table_name = "#{connection_config[:database]}.CDImages"
  self.primary_key = :MediaId

  alias_attribute :last_burn, :LastBurn
end

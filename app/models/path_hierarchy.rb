class PathHierarchy < ActiveRecord::Base
  establish_connection BACULA_CONF

  self.table_name = "#{connection_config[:database]}.PathHierarchy"
  self.primary_key = :PathId

  alias_attribute :path_id, :PathId
  alias_attribute :p_path_id, :PPathId
end

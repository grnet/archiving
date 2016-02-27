class PathVisibility < ActiveRecord::Base
  establish_connection BACULA_CONF

  self.table_name = "#{connection_config[:database]}.PathVisibility"
  self.primary_key = [:JobId, :PathId]

  alias_attribute :path_id, :PathId
  alias_attribute :job_id, :JobId
  alias_attribute :size, :Size
  alias_attribute :files, :Files
end

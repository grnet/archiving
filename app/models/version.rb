class Version < ActiveRecord::Base
  self.table_name = :Version

  alias_attribute :version_id, :VersionId
end

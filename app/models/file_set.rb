class FileSet < ActiveRecord::Base
  self.table_name = :FileSet
  self.primary_key = :FileSetId

  alias_attribute :file_set_id, :FileSetId
  alias_attribute :file_set, :FileSet
  alias_attribute :md5, :MD5
  alias_attribute :create_time, :CreateTime

  has_many :jobs, foreign_key: :FileSetId
end

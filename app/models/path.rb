class Path < ActiveRecord::Base
  self.table_name = :Path
  self.primary_key = :PathId

  alias_attribute :path_id, :PathId
  alias_attribute :path, :Path

  has_many :bacula_files, foreign_key: :PathId
end

# ActiveRecord class for Bacula's File resource
class BaculaFile < ActiveRecord::Base
  self.table_name = :File
  self.primary_key = :FileId

  alias_attribute :file_index, :FileIndex
  alias_attribute :job_id, :JobId
  alias_attribute :path_id, :PathId
  alias_attribute :filename_id, :FilenameId
  alias_attribute :delta_seq, :DeltaSeq
  alias_attribute :mark_id, :MarkId
  alias_attribute :l_stat, :LStat
  alias_attribute :md5, :MD5

  belongs_to :path, foreign_key: :PathId
  belongs_to :filename, foreign_key: :FilenameId
  belongs_to :job, foreign_key: :JobId

  has_many :base_files, foreign_key: :FileId
end

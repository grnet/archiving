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
end

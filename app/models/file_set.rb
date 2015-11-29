# Bacula FileSet table.
#
# The FileSet table contains one entry for each FileSet that is used.
# The MD5 signature is kept to ensure that if the user changes anything inside the FileSet,
#  it will be detected and the new FileSet will be used.
# This is particularly important when doing an incremental update.
# If the user deletes a file or adds a file, we need to ensure that a Full backup is done
# prior to the next incremental.
class FileSet < ActiveRecord::Base
  self.table_name = :FileSet
  self.primary_key = :FileSetId

  alias_attribute :file_set_id, :FileSetId
  alias_attribute :file_set, :FileSet
  alias_attribute :md5, :MD5
  alias_attribute :create_time, :CreateTime

  has_many :jobs, foreign_key: :FileSetId
end

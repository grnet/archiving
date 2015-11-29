# Bacula Filename
#
# The Filename table contains the name of each file backed up with the path removed.
#  If different directories or machines contain the same filename,
# only one copy will be saved in this table.
class Filename < ActiveRecord::Base
  self.table_name = :Filename
  self.primary_key = :FilenameId

  alias_attribute :filename_id, :FilenameId
  alias_attribute :name, :Name

  has_many :bacula_files, foreign_key: :FilenameId
end

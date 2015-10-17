class Client < ActiveRecord::Base
  self.table_name = :Client
  self.primary_key = :ClientId

  alias_attribute :name, :Name
  alias_attribute :uname, :Uname
  alias_attribute :auto_prune, :AutoPrune
  alias_attribute :file_retention, :FileRetention
  alias_attribute :job_retention, :JobRetention

  has_many :jobs, foreign_key: :ClientId
end

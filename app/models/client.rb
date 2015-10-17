class Client < ActiveRecord::Base
  self.table_name = :Client
  self.primary_key = :ClientId
end

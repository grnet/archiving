class Counter < ActiveRecord::Base
  self.table_name = :Counters
  self.primary_key = :Counter
end

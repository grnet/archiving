class Counter < ActiveRecord::Base
  self.table_name = :Counters
  self.primary_key = :Counter

  alias_attribute :counter, :Counter
  alias_attribute :min_value, :MinValue
  alias_attribute :max_value, :MaxValue
  alias_attribute :current_value, :CurrentValue
  alias_attribute :wrap_coounter, :WrapCounter
end

# Bacula Counter table
#
# The Counter table contains one entry for each permanent counter defined by the user.
class Counter < ActiveRecord::Base
  establish_connection BACULA_CONF

  self.table_name = "#{connection_config[:database]}.Counters"
  self.primary_key = :Counter

  alias_attribute :counter, :Counter
  alias_attribute :min_value, :MinValue
  alias_attribute :max_value, :MaxValue
  alias_attribute :current_value, :CurrentValue
  alias_attribute :wrap_coounter, :WrapCounter
end

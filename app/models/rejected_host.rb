# When an admin rejects a host that is pending for verification
# a rejected host is created.
class RejectedHost < ActiveRecord::Base
  establish_connection ARCHIVING_CONF

  belongs_to :user
  belongs_to :rejecter, class: User

  alias_attribute :rejected_at, :created_at
end

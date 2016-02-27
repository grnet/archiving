class Ownership < ActiveRecord::Base
  establish_connection ARCHIVING_CONF

  belongs_to :user
  belongs_to :host
end

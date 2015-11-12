class Ownership < ActiveRecord::Base
  establish_connection Baas::settings[:local_db]

  belongs_to :user
  belongs_to :host
end

class User < ActiveRecord::Base
  establish_connection Baas::settings[:local_db]

  has_many :ownerships
  has_many :hosts, through: :ownerships, inverse_of: :users

  enum user_type: { institutional: 0, vima: 1, okeanos: 2, admin: 3 }

  validates :username, :user_type, presence: true
end

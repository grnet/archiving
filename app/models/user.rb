class User < ActiveRecord::Base
  enum user_type: { institutional: 0, vima: 1, okeanos: 2, admin: 3 }

  validates :username, :user_type, presence: true
end

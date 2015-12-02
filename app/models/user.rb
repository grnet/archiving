class User < ActiveRecord::Base
  has_many :ownerships
  has_many :hosts, through: :ownerships, inverse_of: :users

  enum user_type: { institutional: 0, vima: 1, okeanos: 2, admin: 3 }

  validates :username, :user_type, presence: true

  # Composes the user's display name from the user's username and email
  #
  # @return [String]
  def display_name
    "#{username} <#{email}>"
  end

  # Determines if the user must select hosts from a list or enter their
  # FQDN manually
  #
  # @return [Boolean]
  def needs_host_list?
    vima? || okeanos?
  end

  # Marks a user as not enabled
  def ban
    self.enabled = false
    save
  end

  # Marks a user as enabled
  def unban
    self.enabled = true
    save
  end
end

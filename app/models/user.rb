class User < ActiveRecord::Base
  establish_connection ARCHIVING_CONF

  attr_accessor :password, :retype_password

  serialize :temp_hosts, JSON

  has_many :ownerships
  has_many :hosts, through: :ownerships, inverse_of: :users
  has_many :invitations

  enum user_type: { institutional: 0, vima: 1, okeanos: 2, admin: 3 }

  validates :user_type, presence: true
  validates :username, presence: true, uniqueness: { scope: :user_type }
  validates :email, presence: true, uniqueness: { scope: :user_type }

  before_create :confirm_passwords, if: :admin?

  # Returns an admin user with the given password
  #
  # @param username[String] username from user input
  # @param a_password[String] password from user input
  #
  # @return [User] the admin user or nil
  def self.fetch_admin_with_password(username, a_password)
    hashed_pass = Digest::SHA256.hexdigest(a_password + Rails.application.secrets.salt)
    admin = User.admin.find_by_username_and_password_hash(username, hashed_pass)
    admin
  end

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

  # Determines if the user is editable or not.
  # Editable users are only admin users, all others come from 3rd party authorization
  #
  # @return [Boolean]
  def editable?
    admin?
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

  # Stores a hashed password as a password_hash
  #
  # @param a_password[String] the user submitted password
  #
  # @return [Boolean] the save exit status
  def add_password(a_password)
    self.password_hash = Digest::SHA256.hexdigest(a_password + Rails.application.secrets.salt)
    self.save
  end

  # Fetches the user's unverified hosts
  #
  # @return [Array] of Strings containing the hosts' names
  def unverified_hosts
    hosts.unverified.pluck(:name)
  end

  # Fetches the user's hosts that are being backed up by bacula
  #
  # @return [Array] of Strings configuration the host's names
  def baculized_hosts
    hosts.in_bacula.pluck(:name)
  end

  # Fetches the user's hosts that are NOT being backed up by bacula
  #
  # @return [Array] of Strings configuration the host's names
  def non_baculized_hosts
    hosts.not_baculized.pluck(:name)
  end

  # Determines if a vima user needs to update his hosts' list
  #
  # @return [Boolean]
  def refetch_hosts?
    return false unless vima?
    return true if hosts_updated_at.nil?

    hosts_updated_at < Archiving.settings[:skip_host_fetch_time_period].ago
  end

  private

  def confirm_passwords
    if password.blank?
      self.errors.add(:password, 'Must give a password')
      return false
    end
    if password != retype_password
      self.errors.add(:password, 'Passwords mismatch')
      self.errors.add(:retype_password, 'Passwords mismatch')
      return false
    end

    true
  end
end

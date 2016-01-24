# `Invitation` describes the pending invitation of a user to join a host.
class Invitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :host

  validates :user, :host, :verification_code, presence: true

  before_validation :calculate_verification_code

  private

  def calculate_verification_code
    self.verification_code = Digest::SHA256.hexdigest(
      [host.name, Time.now.to_s, Rails.application.secrets.salt].join
    )
  end
end

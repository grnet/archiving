# `Invitation` describes the pending invitation of a user to join a host.
class Invitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :host

  validates :user, :host, :verification_code, presence: true

  before_validation :calculate_verification_code

  # Sends an email to the user to inform that there is an invitation to
  # handle the client's backups.
  def notify_user
    UserMailer.notify_for_invitation(user.email, self).deliver
  end

  # Fetches the parameters that can be passed to accept_invitation_url in
  #  order to generate the correct url
  #
  # @return [Hash]
  def accept_hash
    {
      host_id: host_id,
      verification_code: verification_code
    }
  end

  private

  def calculate_verification_code
    self.verification_code = Digest::SHA256.hexdigest(
      [host.name, Time.now.to_s, Rails.application.secrets.salt].join
    )
  end
end

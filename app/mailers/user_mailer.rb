class UserMailer < ActionMailer::Base
  default from: Archiving.settings[:default_sender]

  # Notifies the host's owners that the host has been verified by an admin
  # and is now ready to be configured
  #
  # @param user_emails[Array] the owners' emails
  # @param host[String] the host's FQDN
  def notify_for_verification(user_emails, host)
    @host = host
    s = "[Archiving] Host #{host} verification"
    mail(to: user_emails, subject: s)
  end

  # Notifies admin about a new host that needs verification
  #
  # @param user[User] the user that created the host
  # @param host[String] the host's FQDN
  def notify_admin(user, host)
    @user = user
    @host = host
    mail(to: Archiving.settings[:admin_email], subject: 'New host pending verification')
  end
end

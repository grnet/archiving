class UserMailer < ActionMailer::Base
  default from: Archiving.settings[:default_sender]

  # Notifies the host's owners that the host has been verified by an admin
  # and is now ready to be configured
  #
  # @param user_emails[Array] the owners' emails
  # @param host[String] the host's FQDN
  def notify_for_verification(user_emails, host)
    @host = host
    s = "[Archiving] Host #{host.name} verification"
    mail(to: user_emails, subject: s)
  end

  # Notifies the host's owners that the host has been rejected by an admin
  #
  # @param user_emails[Array] the ownerss emails
  # @param host[String] the host's FQDN
  # @param reason[String] the rejection reason
  def notify_for_rejection(user_emails, host, reason)
    @host = host
    @reason = reason
    s = "[Archiving] Host #{host.name} rejection"
    mail(to: user_emails, subject: s)
  end

  # Notifies the user that another user has requested that he should be able to
  # manage the given client's backups
  #
  # @param email[String] the user's email
  # @param invitation[Invitation] the target host
  def notify_for_invitation(email, invitation)
    @invitation = invitation
    subject = "[Archiving] Invitation to manage #{@invitation.host.name}'s backups"
    mail(to: email, subject: subject)
  end

  # Notifies admins about a new host that needs verification
  #
  # @param user[User] the user that created the host
  # @param host[String] the host's FQDN
  def notify_admin(user, host)
    admin_emails = User.admin.where(enabled: true).pluck(:email)
    @user = user
    @host = host
    mail(to: admin_emails, subject: 'New host pending verification')
  end

  # Notifies admins about a host that was verified
  #
  # @param user[User] the admin that verified the host
  # @param host[String] the host's FQDN
  def notify_admin_for_verification(user, host)
    admin_emails = User.admin.where(enabled: true).pluck(:email)
    @user = user
    @host = host
    mail(to: admin_emails, subject: 'New host verification')
  end
end

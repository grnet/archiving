Warden::Strategies.add(:institutional) do
  def valid?
    fetch_header('HTTP_REMOTE_USER').present? &&
      fetch_header('HTTP_MAIL').present? &&
      fetch_header('HTTP_ENTITLEMENT').present? &&
      fetch_header('HTTP_ENTITLEMENT').include?('urn:mace:grnet.gr:archiving:admin')
  end

  def fetch_header(header)
    request.env[header]
  end

  def authenticate!
    Rails.logger.warn("WARDEN: INFO institutional has valid headers")
    if !Archiving.settings[:institutional_authentication_enabled]
      return fail!("Shibboleth is temporarily disabled")
    end

    identifier = "institutional:#{fetch_header("HTTP_REMOTE_USER")}"
    user = User.find_or_initialize_by(identifier: identifier)

    return fail!("Wrong credentials") unless user

    user.login_at = Time.now

    if user.new_record?
      user.email = fetch_header("HTTP_MAIL")
      user.username = fetch_header("HTTP_MAIL")
      user.enabled = true
      user.institutional!
    else
      user.save
    end

    return fail!("Service not available") unless user.enabled?

    success!(user)
  end
end

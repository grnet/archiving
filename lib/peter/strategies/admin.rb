Warden::Strategies.add(:admin) do
  def valid?
    params['username'] && params['password']
  end

  def authenticate!
    admin = User.fetch_admin_with_password(params['username'], params['password'])

    return fail!("Wrong credentials") unless admin
    return fail!("Your account is disabled") unless admin.enabled?

    admin.login_at = Time.now
    admin.save

    success!(admin)
  end
end

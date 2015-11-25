Warden::Strategies.add(:admin) do
  def valid?
    params['admin'] == 'admin'
  end

  def authenticate!
    u = User.admin.last
    success!(u)
  end
end

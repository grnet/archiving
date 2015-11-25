require 'peter/strategies/admin'
require 'peter/strategies/vima'

module Peter
  extend self

  def set_session(user, auth, opts)
    session = auth.session(:default)
  end

  Rails.configuration.middleware.insert_after ActionDispatch::Flash, Warden::Manager do |manager|
    manager.default_strategies :admin, :vima
    manager.failure_app = ApplicationController
  end

  Warden::Manager.serialize_into_session do |user|
    user.id
  end

  Warden::Manager.serialize_from_session do |id|
    User.find_by_id(id)
  end
end

Warden::Manager.after_authentication do |user,auth,opts|
  Peter.set_session(user, auth, opts)
end

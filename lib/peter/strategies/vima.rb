## -*- encoding : utf-8 -*-
require 'oauth2'

Warden::Strategies.add(:vima) do
  Key = Rails.application.secrets.oauth2_vima_client_id
  Secret = Rails.application.secrets.oauth2_vima_secret

  def valid?
    params['vima'] || params['error'] || params['code']
  end

  def client
    OAuth2::Client.new(
      Key,
      Secret,
      site: 'https://vima.grnet.gr',
      token_url: "/o/token",
      authorize_url: "/o/authorize",
      :ssl => {:ca_path => "/etc/ssl/certs"}
    )
  end

  def redirect_uri
    uri = URI.parse(request.url)
    uri.scheme = 'https' unless Rails.env.development?
    uri.path = '/vima'
    uri.query = nil
    uri.to_s
  end

  def redirect_to_vima
    redirect! client.auth_code.authorize_url(:redirect_uri => redirect_uri, scope: 'read')
  end

  def authenticate!
    if !Baas::settings[:vima_oauth_enabled]
      return fail!("ViMa is temporarily disabled")
    end

    if params['error']
      Rails.logger.warn("WARDEN: ERROR #{params['error']}")
      return fail!("ViMa log in failed: #{params['error']}")
    end

    return redirect_to_vima if params['vima']

    access_token = client.auth_code.get_token(
      params['code'],
      { :redirect_uri => redirect_uri },
      { :mode => :query, :param_name => "access_token", :header_format => "" })

    user_data = access_token.get('https://vima.grnet.gr/instances/list?tag=vima:service:archiving',
                                 { mode: :query, param_name: 'access_token' }).
      parsed.deep_symbolize_keys

    user = User.find_or_initialize_by(username: user_data[:user][:username],
                                      email: user_data[:user][:email])
    user.login_at = Time.now

    if user.new_record?
      user.enabled = true
      user.vima!
    else
      user.save!
    end

    if user_data[:response][:errors] != false
      Rails.logger.warn("ViMa: errors on instances/list response for user #{user_data[:user][:username]}")
    end

    if !user.enabled?
      return fail!('Service not available')
    end

    assign_vms(user, user_data[:response][:instances])

    success!(user)
  end

  def assign_vms(user, vms)
    Rails.logger.warn("ViMa: user: #{user.username}")
    Rails.logger.warn("ViMa: vms: #{vms}")
    Rails.logger.warn("ViMa: session vms: #{session[:vms]}")
    session[:vms] = vms.first(50)
    Host.where(fqdn: vms).each do |host|
      host.users << user unless host.users.include?(user)
    end
  end
end

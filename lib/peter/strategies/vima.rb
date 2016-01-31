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
    if !Archiving::settings[:vima_oauth_enabled]
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

    user_data = access_token.get(
      'https://vima.grnet.gr/user/details',
      { mode: :query, param_name: 'access_token' }
    ).parsed.deep_symbolize_keys

    if [user_data[:username], user_data[:email], user_data[:id]].any?(&:blank?)
      return fail!("ViMa login failed: no user data")
    end

    ###### TBR
    # temporary, for user migration
    user = User.find_or_initialize_by(username: user_data[:username],
                                      email: user_data[:email])
    user.identifier = "vima:#{user_data[:id]}"
    ######

    # actual implementation
    #user = User.find_or_initialize_by(identifier: user_data[:identifier])

    if !user.enabled? && user.persisted?
      return fail!('Service not available')
    end

    user.login_at = Time.now

    if user.new_record?
      user.enabled = true
      # TBR
      user.identifier = "vima:#{user_data[:id]}"
      user.vima!
    else
      user.save!
    end

    if user.refetch_hosts?
      vms = fetch_vms(access_token)[:response][:instances]
      user.hosts_updated_at = Time.now
      user.temp_hosts = vms
      user.save
    end

    vms ||= (user.temp_hosts + user.hosts.pluck(:fqdn)).uniq

    assign_vms(user, vms)

    success!(user)
  end

  def fetch_vms(access_token)
    Rails.logger.warn("ViMa: fetching vms")
    vms = access_token.get(
      'https://vima.grnet.gr/instances/list?tag=vima:service:archiving',
      { mode: :query, param_name: 'access_token' }
    ).parsed.deep_symbolize_keys

    if vms[:response][:errors] != false
      Rails.logger.warn("ViMa: errors on instances/list response for user #{vms[:user][:username]}")
    end

    vms
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

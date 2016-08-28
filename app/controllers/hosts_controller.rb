class HostsController < ApplicationController
  before_action :require_logged_in, except: :fd_config
  before_action :fetch_host, only: [:show, :edit, :update, :destroy, :submit_config,
                                    :revoke, :disable]
  before_action :fetch_hosts_of_user, only: [:new, :create]

  # GET /hosts/new
  def new
    @host = Host.new
    @host.port = 9102
    @host.email_recipients = [current_user.email]
  end

  # POST /hosts
  def create
    @host = Host.new(fetch_params)

    set_host_type

    @host.verified = !@host.institutional?

    if user_can_add_this_host? && @host.save
      flash[:success] = 'Host created successfully'
      current_user.hosts << @host
      UserMailer.notify_admin(current_user, @host.fqdn).deliver
      redirect_to host_path @host
    else
      flash[:error] = 'Host was not created'
      render :new
    end
  end

  # GET /hosts/1
  def show
    @schedules = @host.job_templates.map(&:schedule)
    @filesets = @host.job_templates.map(&:fileset)
  end

  # GET /hosts/1/edit
  def edit
    if current_user.needs_host_list?
      @hosts_of_user = current_user.hosts.pluck(:fqdn)
    end
  end

  # PATCH /hosts/1
  def update
    updates = fetch_params.slice(:port, :password, :email_recipients)
    if updates.present? && @host.update_attributes(updates)
      @host.recalculate if @host.bacula_ready?
      flash[:success] = 'Host updated successfully. You must update your file deamon accordingly.'
      redirect_to host_path @host
    else
      render :edit
    end
  end

  # DELETE /hosts/1
  def destroy
    if (@host.client.nil? || @host.remove_from_bacula(true)) && @host.destroy
      flash[:success] = 'Host destroyed successfully'
    else
      flash[:error] = 'Host not destroyed'
    end

    redirect_to root_path
  end

  # POST /hosts/1/disable
  def disable
    if @host.disable_jobs_and_update
      flash[:success] = 'Client disabled'
    else
      flash[:error] = 'Something went wrong, try again later'
    end

    redirect_to host_path(@host)
  end

  # POST /hosts/1/submit_config
  def submit_config
    if @host.dispatch_to_bacula
      flash[:success] = 'Host configuration sent to Bacula successfully'
    else
      flash[:error] = 'Something went wrong, try again later'
    end

    redirect_to host_path(@host)
  end

  # DELETE /hosts/1/revoke
  def revoke
    if @host.remove_from_bacula
      flash[:success] = 'Host configuration removed from Bacula successfully'
    else
      flash[:error] = 'Something went wrong, try again later'
    end

    redirect_to root_path
  end

  # GET /hosts/fetch_vima_hosts
  def fetch_vima_hosts
    if params[:code].blank?
      return redirect_to client.auth_code.authorize_url(:redirect_uri => redirect_uri,
                                                        scope: 'read')
    end

    access_token = client.auth_code.get_token(
      params['code'],
      { :redirect_uri => redirect_uri },
      { :mode => :query, :param_name => "access_token", :header_format => "" }
    )

    vms = access_token.get(
      'https://vima.grnet.gr/instances/list?tag=vima:service:archiving',
      { mode: :query, param_name: 'access_token' }
    ).parsed.deep_symbolize_keys[:response][:instances]

    session[:vms] = vms.first(50)

    current_user.temp_hosts = vms
    current_user.hosts_updated_at = Time.now
    current_user.save

    Host.where(fqdn: vms).each do |host|
      host.users << current_user unless host.users.include?(current_user)
    end

    redirect_to new_host_path
  end

  # GET /hosts/:id/fd_config?token=A_TOKEN
  def fd_config
    user = User.find_by(token: params[:token]) if params[:token]

    return redirect_to clients_path if user.nil?

    @host = user.hosts.find_by(id: params[:id])

    return redirect_to clients_path unless @host

    render text: [
      @host.bacula_fd_filedeamon_config,
      @host.bacula_fd_director_config(false),
      @host.bacula_fd_messages_config
    ].join("\n\n")
  end

  private

  def client
    OAuth2::Client.new(
      Rails.application.secrets.oauth2_vima_client_id,
      Rails.application.secrets.oauth2_vima_secret,
      site: 'https://vima.grnet.gr',
      token_url: "/o/token",
      authorize_url: "/o/authorize",
      :ssl => {:ca_path => "/etc/ssl/certs"}
    )
  end

  def redirect_uri
    uri = URI.parse(request.url)
    uri.scheme = 'https' unless Rails.env.development?
    uri.path = '/hosts/fetch_vima_hosts'
    uri.query = nil
    uri.to_s
  end

  def fetch_hosts_of_user
    return if not current_user.needs_host_list?

    @hosts_of_user = session[:vms] - current_user.hosts.pluck(:fqdn)
  end

  def fetch_host
    @host = current_user.hosts.includes(job_templates: [:fileset, :schedule]).find(params[:id])
  end

  def fetch_params
    params.require(:host).permit(:fqdn, :port, :password, email_recipients: [])
  end

  def user_can_add_this_host?
    !current_user.needs_host_list? || @hosts_of_user.include?(@host.fqdn)
  end

  def set_host_type
    @host.origin = if current_user.vima?
                     :vima
                   elsif current_user.okeanos?
                     :okeanos
                   else
                     :institutional
                   end
  end
end

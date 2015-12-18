class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :warden

  # GET /
  def index
    redirect_to clients_path if current_user
  end

  # Warden handler for authentication failure
  def unauthenticated
    flash[:error] = warden.message || 'There was an error with your login'
    if attempted_path == '/grnet'
      redirect_to admin_login_path
    else
      redirect_to root_path
    end
  end

  # POST /grnet
  def grnet
    if current_user
      warden.logout
      reset_current_user
    end
    begin
      warden.authenticate!(:admin)
    rescue
      return unauthenticated
    end
    current_user
    redirect_to admin_path
  end

  # GET /institutional
  def institutional
    begin
      warden.authenticate!(:institutional)
    rescue
      return unauthenticated
    end
    current_user
    redirect_to clients_path
  end

  # POST /vima
  def vima
    begin
      warden.authenticate!(:vima)
    rescue
      return unauthenticated
    end
    current_user
    redirect_to clients_path
  end

  def logout
    warden.logout
    reset_current_user
    redirect_to root_path
  end

  protected

  def warden
    request.env['warden']
  end

  def current_user
    @current_user ||= warden.user
  end

  def reset_current_user
    @current_user = nil
  end

  def fetch_logs
    days_ago = params.fetch(:days_back, 7).to_i rescue 7

    if @client
      @logs = Log.includes(:job).joins(job: :client).where(Client: { ClientId: @client.id })
    else
      @logs = Log.includes(:job).joins(job: { client: { host: :users } }).
        where(users: { id: current_user.id })
    end
    @logs = @logs.where('Time > ?', days_ago.days.ago).
      order(Time: :desc, LogId: :desc).page(params[:page])
  end

  private

  def require_logged_in
    return if current_user

    flash[:alert] = 'You need to log in first'
    redirect_to root_path
  end

  def attempted_path
    (request.env['warden.options'] || {})[:attempted_path]
  end
end

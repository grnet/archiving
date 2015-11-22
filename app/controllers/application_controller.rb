class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user

  protected

  def current_user
    @current_user ||= User.last
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
end

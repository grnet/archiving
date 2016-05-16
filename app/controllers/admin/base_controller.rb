class Admin::BaseController < ApplicationController
  before_action :require_admin, except: [:login]

  # GET /admin
  # POST /admin
  def index
    @client_ids = Client.pluck(:ClientId)
    get_charts
    @global_stats = GlobalStats.new.stats
    render 'admin/index'
  end

  # GET /admin/login
  def login
    render 'admin/login'
  end

  protected

  def get_charts
    @job_status = ChartGenerator.job_statuses(@client_ids, days_ago)
    @job_stats = ChartGenerator.job_stats(@client_ids, days_ago - 1)
  end

  def require_admin
    return if current_user.try(:has_admin_access?)

    flash[:alert] = 'You need to log in first'
    redirect_to admin_login_path
  end
end

class Admin::BaseController < ApplicationController
  before_action :require_admin

  # GET /admin
  # POST /admin
  def index
    @client_ids = Client.pluck(:ClientId)
    get_charts
    render 'admin/index'
  end

  protected

  def get_charts
    days_ago = params.fetch(:days_back, 7).to_i rescue 7
    @job_status = ChartGenerator.job_statuses(@client_ids, days_ago)
    @job_stats = ChartGenerator.job_stats(@client_ids, days_ago - 1)
  end

  def require_admin
    return if current_user.try(:admin?)

    flash[:alert] = 'You need to log in first'
    redirect_to root_path
  end
end

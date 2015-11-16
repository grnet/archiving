class ClientsController < ApplicationController
  before_action :set_client, only: :show

  # GET /clients
  def index
    @client_ids = Client.for_user(current_user.id).pluck(:ClientId)
    @clients = Client.where(ClientId: @client_ids).includes(:jobs)
    @active_jobs = Job.running.where(ClientId: @client_ids).group(:ClientId).count
    @hosts = current_user.hosts.not_baculized
    get_charts
  end

  # GET /clients/1
  def show
    @client_ids = [@client.id]
    get_charts
  end

  private

  def set_client
    @client = Client.for_user(current_user.id).find(params[:id])
  end

  def get_charts
    days_ago = params.fetch(:days_back, 7).to_i rescue 7
    @job_status = ChartGenerator.job_statuses(@client_ids, days_ago)
    @job_stats = ChartGenerator.job_stats(@client_ids, days_ago - 1)
  end
end

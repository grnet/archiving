class ClientsController < ApplicationController
  before_action :require_logged_in
  before_action :set_client, only: [:show, :jobs, :logs, :stats, :users]
  before_action :fetch_logs, only: [:logs]

  # GET /clients
  # POST /clients
  def index
    @client_ids = Client.for_user(current_user.id).pluck(:ClientId)
    @clients = Client.where(ClientId: @client_ids).includes(:jobs)
    @hosts = current_user.hosts.not_baculized
    fetch_jobs_info
    get_charts
  end

  # GET /clients/1
  def show
    @schedules = @client.host.job_templates.map(&:schedule)
    @filesets = @client.host.job_templates.map(&:fileset)
  end

  # GET /clients/1/jobs
  def jobs
    @jobs = @client.recent_jobs.page(params[:page])
  end

  # GET /clients/1/logs
  def logs; end

  # GET /clients/1/stats
  # POST /clients/1/stats
  def stats
    get_charts
  end

  # GET /clients/1/users
  def users
    @users = @client.host.users
  end

  private

  def set_client
    @client = Client.for_user(current_user.id).find(params[:id])
    @client_ids = [@client.id]
  end

  def fetch_jobs_info
    @stats = JobStats.new(@client_ids)
  end

  def get_charts
    days_ago = params.fetch(:days_back, 7).to_i rescue 7
    @job_status = ChartGenerator.job_statuses(@client_ids, days_ago)
    @job_stats = ChartGenerator.job_stats(@client_ids, days_ago - 1)
  end
end

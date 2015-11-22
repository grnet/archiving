class Admin::ClientsController < Admin::BaseController
  before_action :fetch_client, only: [:show, :jobs, :logs, :stats]
  before_action :fetch_logs, only: [:logs]

  # Shows all available clients
  #
  # GET /admin/clients
  def index
    @clients = Client.includes(:jobs).all
    @client_ids = @clients.map(&:id)
    fetch_jobs_info
  end

  # Shows a specific client
  #
  # GET /admin/clients/1
  def show
    get_charts
  end

  # GET /admin/clients/1/jobs
  def jobs; end

  # GET /admin/clients/1/logs
  def logs
  end

  # GET /admin/clients/1/stats
  # POST /admin/clients/1/stats
  def stats
    get_charts
  end

  private

  # Fetches the client based on the given id
  def fetch_client
    @client = Client.find(params[:id])
    @client_ids = [@client.id]
  end

  def fetch_jobs_info
    @stats = JobStats.new
  end

  def get_charts
    days_ago = params.fetch(:days_back, 7).to_i rescue 7
    @job_status = ChartGenerator.job_statuses(@client_ids, days_ago)
    @job_stats = ChartGenerator.job_stats(@client_ids, days_ago - 1)
  end
end

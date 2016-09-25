class Admin::ClientsController < Admin::BaseController
  before_action :fetch_client, only: [:show, :jobs, :logs, :stats, :configuration,
                                      :disable, :revoke, :block, :unblock]
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
    if !@client.host.present?
      flash[:alert] = 'Client not configured through Archiving'
      return redirect_to admin_clients_path
    end

    get_charts
  end

  # GET /admin/clients/1/jobs
  def jobs
    @jobs = @client.recent_jobs.page(params[:page])
  end

  # GET /admin/clients/1/logs
  def logs
  end

  # GET /admin/clients/1/stats
  # POST /admin/clients/1/stats
  def stats
    get_charts
  end

  # GET /admin/clients/1/configuration
  def configuration
  end

  # POST /admin/clients/1/disable
  def disable
    if @client.host.disable_jobs_and_update
      flash[:success] = 'Client disabled'
    else
      flash[:error] = 'Something went wrong, try again later'
    end

    redirect_to admin_client_path(@client)
  end

  # POST /admin/clients/1/block
  def block
    if @client.host.disable_jobs_and_lock
      flash[:success] = 'Client is disabled and locked'
    else
      flash[:error] = 'Something went wrong, try again'
    end

    redirect_to admin_client_path(@client)
  end

  # POST /admin/clients/1/unblock
  def unblock
    if @client.host.unblock
      flash[:success] = 'Client can now be configured by users'
    else
      flash[:error] = 'Client is still locked'
    end

    redirect_to admin_client_path(@client)
  end

  # DELETE /admin/clients/1/revoke
  def revoke
    if @client.host.remove_from_bacula(true)
      flash[:success] = 'Client removed. It will be visible to until its jobs get cleaned up'
    else
      flash[:error] = 'Something went wrong, try again later'
    end

    redirect_to admin_clients_path
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
    @job_status = ChartGenerator.job_statuses(@client_ids, days_ago)
    @job_stats = ChartGenerator.job_stats(@client_ids, days_ago - 1)
  end
end

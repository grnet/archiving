class ClientsController < ApplicationController
  before_action :require_logged_in
  before_action :fetch_client, only: [:show, :jobs, :logs, :stats, :users, :restore, :run_restore]
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

  # GET /clients/1/restore
  def restore
    return if @client.is_backed_up?

    flash[:error] = 'Can not issue a restore for this client'
    redirect_to client_path(@client)
  end

  # POST /clients/1/run_restore
  def run_restore
    location = params[:restore_location].blank? ? '/tmp/bacula-restore' : params[:restore_location]
    fileset = params[:fileset]
    restore_point = fetch_restore_point
    if location.nil? || fileset.nil? || !@client.host.restore(fileset, location, restore_point)
      flash[:error] = 'Something went wrong, try again later'
    else
      flash[:success] =
        "Restore job issued successfully, files will be soon available in #{location}"
    end

    redirect_to client_path(@client)
  end

  private

  def fetch_client
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

  def fetch_restore_point
    if params['restore_time(4i)'].blank? || params['restore_time(5i)'].blank? ||
        params[:restore_date].blank?
      return nil
    end
    restore_point =
      "#{params[:restore_date]} #{params['restore_time(4i)']}:#{params['restore_time(5i)']}:00"
    begin
      DateTime.strptime(restore_point, '%Y-%m-%d %H:%M:%S')
    rescue
      return nil
    end
    restore_point
  end
end

class ClientsController < ApplicationController
  before_action :require_logged_in
  before_action :fetch_client, only: [:show, :jobs, :logs, :stats, :users, :restore, :run_restore,
                                      :restore_selected, :remove_user]
  before_action :fetch_logs, only: [:logs]
  before_action :require_non_blocked_client, only: [:restore, :restore_selected, :run_restore]

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
    @jobs = @client.jobs.backup_type.terminated.group(:name).maximum(:EndTime)
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
    if @client.manually_inserted?
      @invitation = @client.host.invitations.new
      excluded_ids = @users.pluck(:id) + @client.host.invitations.pluck(:user_id)
      @available_users = User.where(enabled: true).institutional.
        where.not(id: excluded_ids).pluck(:username, :id)
    end
  end

  # DELETE /clients/1/user
  def remove_user
    user = @client.host.users.find(params[:user_id])
    redirect_path = users_client_path(@client)

    if @client.host.users.count == 1
      flash[:alert] = 'You can not remove the last user'
    elsif @client.host.users.delete(user)
      flash[:success] =
        if @client.manually_inserted?
          'User successfully removed'
        else
          'User must be removed from the VM\'s list from your VM provider too (ViMa or Okeanos).'
        end
      if user.id == current_user.id
        redirect_path = clients_path
      end
    else
      flash[:alert] = 'User not removed, something went wrong'
    end

    redirect_to redirect_path
  end

  # GET /clients/1/restore
  def restore
    @restore_clients = Client.for_user(current_user.id)

    return if @client.is_backed_up?

    flash[:error] = 'Can not issue a restore for this client'
    redirect_to client_path(@client)
  end

  # POST /clients/1/run_restore
  def run_restore
    @location = params[:restore_location].blank? ? '/tmp/bacula_restore' : params[:restore_location]
    fileset = params[:fileset]
    fetch_restore_point
    fetch_restore_client

    if params[:commit] == 'Restore All Files'
      if @location.nil? || fileset.nil? ||
        !@client.host.restore(fileset, @location, @restore_point, @restore_client)
        flash[:error] = 'Something went wrong, try again later'
      else
        msg = "Restore job issued successfully, files will be soon available in #{@location}"
        msg << " of client #{@restore_client}" if @restore_client.present?
        flash[:success] = msg
      end
      render js: "window.location = '#{client_path(@client)}'"
    else
      session[:job_ids] = @client.get_job_ids(fileset, @restore_point)
      session[:restore_client] = @restore_client
      Bvfs.new(@client, session[:job_ids]).update_cache
      render 'select_files'
    end
  end

  # POST /clients/1/restore_selected
  def restore_selected
    Bvfs.new(@client, session[:job_ids]).
      restore_selected_files(params[:files], params[:location], nil, session[:restore_client])
    session.delete(:job_ids)
    session.delete(:restore_client)
    flash[:success] =
      "Restore job issued successfully, files will be soon available in #{params[:location]}"
    redirect_to client_path(@client)
  end

  # GET /clients/1/tree?id=1
  def tree
    @client = Client.for_user(current_user.id).find(params[:client_id])
    bvfs = Bvfs.new(@client, session[:job_ids])
    pathid = params[:id].to_i

    if pathid.nonzero?
      bvfs.fetch_dirs(pathid)
    else
      bvfs.fetch_dirs
    end

    tree = bvfs.extract_dir_id_and_name.map do |id, name|
      { id: id, text: name, state: { checkbox_disabled: true }, children: true }
    end

    if pathid.nonzero?
      bvfs.fetch_files(pathid)
      bvfs.extract_file_id_and_name.each do |id, name|
        tree << { id: id, text: name, type: 'file' }
      end
    end

    render json: tree
  end

  private

  def require_non_blocked_client
    if @client.host.blocked?
      flash[:error] = 'Client disabled by admins'
      redirect_to clients_path
    end
  end

  def fetch_client
    @client = Client.for_user(current_user.id).find(params[:id])
    @client_ids = [@client.id]
  end

  def fetch_restore_client
    if params[:restore_client]
      @restore_client = Client.for_user(current_user.id).find_by(ClientId: params[:restore_client]).try(:name)
    end
  end

  def fetch_jobs_info
    @stats = JobStats.new(@client_ids)
  end

  def get_charts
    @job_status = ChartGenerator.job_statuses(@client_ids, days_ago)
    @job_stats = ChartGenerator.job_stats(@client_ids, days_ago - 1)
  end

  def fetch_restore_point
    if params['restore_time(4i)'].blank? || params['restore_time(5i)'].blank? ||
        params[:restore_date].blank?
      return nil
    end
    @restore_point =
      begin
        DateTime.strptime(
          "#{params[:restore_date]} #{params['restore_time(4i)']}:#{params['restore_time(5i)']}:00",
          '%Y-%m-%d %H:%M:%S')
      rescue
        nil
      end
  end
end

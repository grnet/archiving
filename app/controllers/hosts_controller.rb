class HostsController < ApplicationController
  before_action :require_logged_in
  before_action :fetch_host, only: [:show, :edit, :update, :destroy, :submit_config,
                                    :revoke, :disable]
  before_action :fetch_hosts_of_user, only: [:new, :edit, :create]

  # GET /hosts/new
  def new
    @host = Host.new
    @host.port = 9102
  end

  # POST /hosts
  def create
    @host = Host.new(fetch_params)

    @host.verified = current_user.needs_host_list?

    if user_can_add_this_host? && @host.save
      flash[:success] = 'Host created successfully'
      current_user.hosts << @host
      redirect_to host_path @host
    else
      flash[:error] = 'Host was not created'
      render :new
    end
  end

  # GET /hosts/1
  def show
    @schedules = @host.job_templates.map(&:schedule)
    @filesets = @host.job_templates.map(&:fileset)
  end

  # GET /hosts/1/edit
  def edit; end

  # PATCH /hosts/1
  def update
    updates = fetch_params.slice(:port, :password)
    if updates.present? && @host.update_attributes(updates)
      @host.recalculate if @host.bacula_ready?
      flash[:success] = 'Host updated successfully. You must update your file deamon accordingly.'
      redirect_to host_path @host
    else
      render :edit
    end
  end

  # DELETE /hosts/1
  def destroy
    if @host.destroy
      flash[:success] = 'Host destroyed successfully'
    else
      flash[:error] = 'Host not destroyed'
    end

    redirect_to root_path
  end

  # POST /hosts/1/disable
  def disable
    if @host.disable_jobs_and_update
      flash[:success] = 'Client disabled'
    else
      flash[:error] = 'Something went wrong, try again later'
    end

    redirect_to host_path(@host)
  end

  # POST /hosts/1/submit_config
  def submit_config
    if @host.dispatch_to_bacula
      flash[:success] = 'Host configuration sent to Bacula successfully'
    else
      flash[:error] = 'Something went wrong, try again later'
    end

    redirect_to host_path(@host)
  end

  # DELETE /hosts/1/revoke
  def revoke
    if @host.remove_from_bacula
      flash[:success] = 'Host configuration removed from Bacula successfully'
    else
      flash[:error] = 'Something went wrong, try again later'
    end

    redirect_to root_path
  end

  private

  def fetch_hosts_of_user
    return if not current_user.needs_host_list?

    @hosts_of_user = session[:vms] - current_user.hosts.pluck(:fqdn)
  end

  def fetch_host
    @host = current_user.hosts.includes(job_templates: [:fileset, :schedule]).find(params[:id])
  end

  def fetch_params
    params.require(:host).permit(:fqdn, :port, :password)
  end

  def user_can_add_this_host?
    !current_user.needs_host_list? || @hosts_of_user.include?(@host.fqdn)
  end
end

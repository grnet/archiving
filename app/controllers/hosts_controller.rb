class HostsController < ApplicationController
  before_action :require_logged_in
  before_action :fetch_host, only: [:show, :edit, :update, :destroy, :submit_config,
                                    :revoke, :restore, :run_restore]

  # GET /hosts/new
  def new
    @host = Host.new
  end

  # POST /hosts
  def create
    @host = Host.new(fetch_params)
    if @host.save
      flash[:success] = 'Host created successfully'
      current_user.hosts << @host
      redirect_to host_path @host
    else
      flash[:error] = 'Host was not created'
      render :new
    end
  end

  # GET /hosts/1
  def show; end

  # GET /hosts/1/edit
  def edit; end

  # PATCH /hosts/1
  def update
    updates = fetch_params.slice(:port, :password)
    if updates.present? && @host.update_attributes(updates)
      @host.recalculate
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

  # GET /hosts/1/restore
  def restore
    if !@host.restorable?
      flash[:error] = "Can not issue a restore for this client"
      redirect_to @host.client.present? ? client_path(@host.client) : root_path
    end
  end

  # POST /hosts/1/run_estore
  def run_restore
    location = params[:restore_location]
    if location.present? && @host.restore(location)
      flash[:success] = "Restore job issued successfully, files will be soon available in #{location}"
    else
      flash[:error] = 'Something went wrong, try again later'
    end

    redirect_to client_path(@host.client)
  end

  private

  def fetch_host
    @host = current_user.hosts.includes(job_templates: [:fileset, :schedule]).find(params[:id])
  end

  def fetch_params
    params.require(:host).permit(:fqdn, :port, :password)
  end
end

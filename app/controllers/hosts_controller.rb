class HostsController < ApplicationController
  before_action :fetch_host, only: [:show, :edit, :update, :destroy, :submit_config, :revoke]

  # GET /hosts
  def new
    @host = Host.new
  end

  # POST /hosts
  def create
    @host = Host.new(fetch_params)
    if @host.save
      redirect_to host_path @host
    else
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
      redirect_to host_path @host
    else
      render :edit
    end
  end

  # DELETE /hosts/1
  def destroy
    @host.destroy
    redirect_to root_path
  end

  # POST /hosts/1/submit_config
  def submit_config
    @host.dispatch_to_bacula
    redirect_to host_path(@host)
  end

  # DELETE /hosts/1/revoke
  def revoke
    @host.remove_from_bacula
    redirect_to root_path
  end

  private

  def fetch_host
    @host = Host.includes(job_templates: [:fileset, :schedule]).find(params[:id])
  end

  def fetch_params
    params.require(:host).permit(:fqdn, :port, :password)
  end
end

class HostsController < ApplicationController
#  before_action :fetch_params, only: :create
  before_action :fetch_host, only: [:show, :edit, :update, :destroy]

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

  # PUT /hosts/1
  def update;end

  # DELETE /hosts/1
  def destroy
    @host.destroy
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

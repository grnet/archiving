class HostsController < ApplicationController
#  before_action :fetch_params, only: :create

  def new
    @host = Host.new
  end

  def create
    @host = Host.new(fetch_params)
    if @host.save
      redirect_to root_path
    else
      render :new
    end
  end

  private

  def fetch_params
    params.require(:host).permit(:name, :fqdn, :port, :password)
  end
end

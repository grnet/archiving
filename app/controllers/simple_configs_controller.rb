class SimpleConfigsController < ApplicationController
  before_action :require_logged_in
  before_action :fetch_host

  # GET /hosts/1/simple_configs/new
  def new
    @simple_config = @host.simple_configurations.new
    @simple_config.randomize
  end

  # POST /hosts/1/simple_configs
  def create
    @simple_config = @host.simple_configurations.new(fetch_config_params)
    @simple_config.save
    @simple_config.create_config
    redirect_to host_path(@host, anchor: :jobs)
  end

  private

  def fetch_host
    @host = current_user.hosts.find(params[:host_id])
  end

  def fetch_config_params
    params.require(:simple_configuration).permit(:name, :day, :hour, :minute)
  end
end

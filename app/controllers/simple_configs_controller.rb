class SimpleConfigsController < ApplicationController
  before_action :require_logged_in
  before_action :fetch_host

  # GET /hosts/1/simple_configs/new
  def new
    @simple_config = SimpleConfiguration.new
    @simple_config.randomize
  end

  # POST /hosts/1/simple_configs
  def create
    @simple_config = SimpleConfiguration.new(fetch_config_params)

    if @simple_config.valid? && @simple_config.create_config(@host)
      redirect_to host_path(@host, anchor: :jobs)
    else
      render :new
    end
  end

  private

  def fetch_host
    @host = current_user.hosts.find(params[:host_id])
  end

  def fetch_config_params
    params.require(:simple_configuration).permit(:name, :day, :hour, :minute, included_files: [])
  end
end

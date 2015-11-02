class SchedulesController < ApplicationController
  before_action :fetch_host, only: [:new, :create]

  def new
    @schedule = @host.schedules.new
  end

  def show
  end

  def edit
  end

  def update
  end

  def create
    @schedule = @host.schedules.new(fetch_params)

    @schedule.runtime = params[:schedule][:runtime] if params[:schedule][:runtime]

    if @schedule.save
      redirect_to host_path(@host)
    else
      render :new
    end
  end

  def destroy
  end

  private

  def fetch_host
    @host = Host.find(params[:host_id])
  end

  def fetch_params
    params.require(:schedule).permit(:name)
  end
end

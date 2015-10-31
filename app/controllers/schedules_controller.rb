class SchedulesController < ApplicationController
  def new
    @schedule = Schedule.new
  end

  def show
  end

  def edit
  end

  def update
  end

  def create
    @schedule = Schedule.new(fetch_params)
    @schedule.runtime = params[:schedule][:runtime] if params[:schedule][:runtime]

    if @schedule.save
      redirect_to root_path
    else
      render :new
    end
  end

  def destroy
  end

  private

  def fetch_params
    params.require(:schedule).permit(:name)
  end
end

class SchedulesController < ApplicationController
  before_action :require_logged_in
  before_action :fetch_host, only: [:new, :create, :show, :edit, :update]
  before_action :fetch_job_id, only: [:new, :create, :show, :edit, :update]
  before_action :fetch_schedule, only: [:show, :edit, :update]

  def new
    @schedule = @host.schedules.new
    @schedule.schedule_runs.build
  end

  def show
    respond_to do |format|
      format.js {}
    end
  end

  def edit
  end

  def update
    if @schedule.update(fetch_params)
      flash[:success] = 'Schedule updated successfully'
      if @job_id
        redirect_to edit_host_job_path(@host, @job_id, schedule_id: @schedule.id)
      else
        redirect_to new_host_job_path(@host, schedule_id: @schedule.id)
      end
    else
      render :edit
    end
  end

  def create
    @schedule = @host.schedules.new(fetch_params)

    @schedule.runtime = params[:schedule][:runtime] if params[:schedule][:runtime]

    if @schedule.save
      flash[:success] = 'Schedule created successfully'
      if @job_id.present?
        redirect_to edit_host_job_path(@host, @job_id, schedule_id: @schedule.id)
      else
        redirect_to new_host_job_path(@host, schedule_id: @schedule.id)
      end
    else
      render :new
    end
  end

  def destroy
  end

  private

  def fetch_schedule
    @schedule = @host.schedules.find(params[:id])
  end

  def fetch_host
    @host = current_user.hosts.find(params[:host_id])
  end

  def fetch_job_id
    @job_id = @host.job_templates.find(params[:job_id]).id if params[:job_id].present?
  end

  def fetch_params
    params.require(:schedule).
      permit(:name, { schedule_runs_attributes: [[:id, :level, :month, :day, :time]] })
  end
end

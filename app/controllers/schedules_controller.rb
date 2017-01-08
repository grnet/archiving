class SchedulesController < ApplicationController
  before_action :require_logged_in
  before_action :fetch_host, only: [:new, :create, :show, :edit, :update]
  before_action :fetch_job_id, only: [:new, :create, :show, :edit, :update]
  before_action :fetch_schedule, only: [:show, :edit, :update]

  # GET /hosts/:host_id/schedules/new
  def new
    @schedule = @host.schedules.new
    @schedule.schedule_runs.build.default_run
  end

  # GET /hosts/:host_id/schedules/:id
  def show
    respond_to do |format|
      format.js {}
    end
  end

  # GET /hosts/:host_id/schedules/:id/edit
  def edit
  end

  # PATCH /hosts/:host_id/schedules/:id
  def update
    if @schedule.update(fetch_params)
      flash[:success] = 'Schedule updated successfully'
      participating_hosts = @schedule.participating_hosts
      if participating_hosts.size.nonzero?
        participating_hosts.each(&:recalculate)
        flash[:alert] = "You will need to redeploy the afffected clients: " +
          participating_hosts.map(&:name).join(', ')
      end
      if @job_id
        redirect_to edit_host_job_path(@host, @job_id, schedule_id: @schedule.id)
      else
        redirect_to new_host_job_path(@host, schedule_id: @schedule.id)
      end
    else
      render :edit
    end
  end

  # POST /hosts/:host_id/schedules
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

  # DELETE /hosts/:host_id/schedules/:id
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
    params[:schedule][:schedule_runs_attributes].each do |sched, attrs|
      hour = attrs.delete('time_wrapper(4i)')
      minute = attrs.delete('time_wrapper(5i)')
      attrs[:time] = Time.new.change(hour: hour, min: minute).strftime('%H:%M')
      params[:schedule][:schedule_runs_attributes][sched] = attrs
    end
    params.require(:schedule).
      permit(:name, { schedule_runs_attributes: [[:id, :level, :month, :day, :time, :_destroy]] })
  end
end

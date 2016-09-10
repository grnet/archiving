class JobsController < ApplicationController
  before_action :require_logged_in
  before_action :fetch_host, only: [:new, :edit, :show, :create, :update, :destroy,
                                    :toggle_enable, :backup_now]
  before_action :fetch_job, only: [:show, :edit, :update, :destroy, :toggle_enable, :backup_now]

  # GET /jobs
  def new
    @job = @host.job_templates.new
    @schedule = @host.schedules.find(params[:schedule_id]) if params[:schedule_id]
  end

  # POST /jobs
  def create
    @job = @host.job_templates.new(fetch_params)
    if @job.save
      flash[:success] = 'Job created successfully'
      redirect_to host_path(@host)
    else
      render :new
    end
  end

  # GET /jobs/1
  def show; end

  # GET /jobs/1/edit
  def edit
    @fileset = @host.filesets.find(params[:fileset_id]) if params[:fileset_id]
    @schedule = @host.schedules.find(params[:schedule_id]) if params[:schedule_id]
  end

  # PUT /jobs/1
  def update
    if @job.update_attributes(fetch_params)
      flash[:success] = 'Job updated'
      redirect_to host_job_path(@host, @job)
    else
      render :edit
    end
  end

  # DELETE /jobs/1
  def destroy
    if @job.destroy
      flash[:success] = 'Job deleted'
      @host.recalculate
      redirect_to host_path(@host)
    else
      flash[:error] = 'Job not deleted'
      redirect_to host_job_path(@host, @job)
    end
  end

  # PATCH /hosts/1/jobs/1/enable
  def toggle_enable
    @job.enabled = !@job.enabled
    @job.save
    flash[:success] = @job.enabled? ? 'Job enabled' : 'Job disabled'

    redirect_to host_path(@host, anchor: :tab_jobs)
  end

  # POST /hosts/1/jobs/1/backup_now
  def backup_now
    if @job.backup_now
      flash[:success] = 'Backup directive was sent to bacula. Backup will be taken in a while'
    else
      flash[:error] = 'Backup was not sent, try again later'
    end

    redirect_to client_path(@host.client)
  end

  private

  def fetch_job
    @job = @host.job_templates.find(params[:id])
  end

  def fetch_host
    @host = current_user.hosts.find(params[:host_id])
  end

  def fetch_params
    params.require(:job_template).
      permit(:name, :fileset_id, :schedule_id, :client_before_run_file, :client_after_run_file)
  end
end

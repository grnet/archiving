class JobsController < ApplicationController
  before_action :fetch_job, only: [:show, :edit, :update, :destroy, :toggle_enable]
  before_action :fetch_host, only: [:new, :edit, :show, :create, :update, :toggle_enable]

  # GET /jobs
  def new
    @job = @host.job_templates.new
  end

  # POST /jobs
  def create
    @job = @host.job_templates.new(fetch_params)
    if @job.save
      redirect_to host_path(@host)
    else
      render :new
    end
  end

  # GET /jobs/1
  def show; end

  # GET /jobs/1/edit
  def edit;end

  # PUT /jobs/1
  def update
    if @job.update_attributes(fetch_params)
      redirect_to host_job_path(@host, @job)
    else
      render :edit
    end
  end

  # DELETE /jobs/1
  def destroy
  end

  # PATCH /hosts/1/jobs/1/enable
  def toggle_enable
    @job.enabled = !@job.enabled
    @job.save
    redirect_to host_path(@host)
  end

  private

  def fetch_job
    @job = JobTemplate.find(params[:id])
  end

  def fetch_host
    @host = Host.find(params[:host_id])
  end

  def fetch_params
    params.require(:job_template).permit(:name, :fileset_id, :schedule_id)
  end
end

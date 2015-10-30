class JobsController < ApplicationController
  before_action :fetch_job, only: [:show, :edit, :update, :destroy]

  # GET /jobs
  def new
    @job_template = JobTemplate.new
  end

  # POST /jobs
  def create
    @job_template = JobTemplate.new(fetch_params)
  end

  # GET /jobs/1
  def show; end

  # GET /jobs/1/edit
  def edit;end

  # PUT /jobs/1
  def update;end

  # DELETE /jobs/1
  def destroy
  end

  private

  def fetch_job
    @job_template = JobTemplate.find(params[:id])
  end

  def fetch_params
    params.require(:job_template).permit(:name, :job_type, :fileset_id, :schedule_id)
  end
end

class FilesetsController < ApplicationController
  before_action :fetch_host, only: [:new, :create]
  before_action :fetch_job_id, only: [:new, :create]

  def new
    @fileset = @host.filesets.new
  end

  def show
  end

  def create
    @fileset = @host.filesets.new(fetch_params)

    if @fileset.save
      if @job_id.present?
        redirect_to edit_host_job_path(@host, @job_id, fileset_id: @fileset.id)
      else
        redirect_to new_host_job_path(@host, fileset_id: @fileset.id)
      end
    else
      @fileset.include_files = nil
      @fileset.exclude_directions = nil
      render :new
    end
  end

  def destroy
  end

  private

  def fetch_host
    @host = current_user.hosts.find(params[:host_id])
  end

  def fetch_job_id
    @job_id = @host.job_templates.find(params[:job_id]).id if params[:job_id].present?
  end

  def fetch_params
    params.require(:fileset).permit(:name, exclude_directions: [], include_files: [])
  end
end

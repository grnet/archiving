class FilesetsController < ApplicationController
  before_action :fetch_host, only: [:new, :create]

  def new
    @fileset = @host.filesets.new
  end

  def show
  end

  def create
    @fileset = @host.filesets.new(fetch_params)

    if @fileset.save
      redirect_to host_path(@host)
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
    @host = Host.find(params[:host_id])
  end

  def fetch_params
    params.require(:fileset).permit(:name, exclude_directions: [], include_files: [])
  end
end

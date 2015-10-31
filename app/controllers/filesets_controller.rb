class FilesetsController < ApplicationController
  def new
    @fileset = Fileset.new
  end

  def show
  end

  def create
    @fileset = Fileset.new(fetch_params)

    if @fileset.save
      redirect_to root_path
    else
      render :new
    end
  end

  def destroy
  end

  private

  def fetch_params
    params.require(:fileset).permit(:name, exclude_directions: [], include_files: [])
  end
end

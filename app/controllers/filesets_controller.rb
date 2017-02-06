class FilesetsController < ApplicationController
  before_action :require_logged_in
  before_action :fetch_host, only: [:new, :create, :show, :edit, :update]
  before_action :fetch_job_id, only: [:new, :create, :edit, :update, :show]
  before_action :fetch_fileset, only: [:show, :edit, :update]

  # GET /hosts/:host_id/filesets/new
  def new
    @fileset = @host.filesets.new
    @fileset.include_directions = { 'file' => [nil] }
    @fileset.exclude_directions = ['']
  end

  # GET /hosts/:host_id/filesets/:id
  def show
    @fileset = @host.filesets.find(params[:id])

    respond_to do |format|
      format.js {}
    end
  end

  # GET /hosts/:host_id/filesets/:id/edit
  def edit
    @fileset.include_files = @fileset.include_directions['file']
    @fileset.exclude_directions = [''] if @fileset.exclude_directions.empty?
  end

  # PATCH /hosts/:host_id/filesets/:id/
  def update
    fileset_params = fetch_params
    if fileset_params[:exclude_directions].nil?
      fileset_params[:exclude_directions] = []
    end

    if @fileset.update(fileset_params)
      flash[:success] = 'Fileset updated successfully'
      participating_hosts = @fileset.participating_hosts
      if participating_hosts.size.nonzero?
        participating_hosts.each(&:recalculate)
        flash[:alert] = 'You will need to redeploy the afffected clients: ' +
                        participating_hosts.map(&:name).join(', ')
      end
      if @job_id
        redirect_to edit_host_job_path(@host, @job_id, fileset_id: @fileset.id)
      else
        redirect_to new_host_job_path(@host, fileset_id: @fileset.id)
      end
    else
      render :edit
    end
  end

  # POST /hosts/:host_id/filesets
  def create
    @fileset = @host.filesets.new(fetch_params)

    if @fileset.save
      flash[:success] = 'Fileset created'
      if @job_id.present?
        redirect_to edit_host_job_path(@host, @job_id, fileset_id: @fileset.id)
      else
        redirect_to new_host_job_path(@host, fileset_id: @fileset.id)
      end
    else
      @fileset.include_files = nil
      @fileset.exclude_directions = ['']
      @fileset.include_directions = { 'file' => [nil] }
      render :new
    end
  end

  # DELETE /hosts/:host_id/filesets/:id
  def destroy
  end

  private

  def fetch_host
    @host = current_user.hosts.find(params[:host_id])
  end

  def fetch_job_id
    @job_id = @host.job_templates.find(params[:job_id]).id if params[:job_id].present?
  end

  def fetch_fileset
    @fileset = @host.filesets.find(params[:id])
  end

  def fetch_params
    params.require(:fileset).permit(:name, exclude_directions: [], include_files: [])
  end
end

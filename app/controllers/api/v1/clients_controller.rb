class Api::V1::ClientsController < Api::BaseController
  before_action :require_api_login
  before_action :fetch_host, only: [:show, :backup, :restore]
  before_action :require_non_blocked_client, only: [:backup, :restore]

  # GET /api/clients
  def index
    hosts = current_api_user.hosts.in_bacula

    api_render(hosts)
  end

  # GET /api/clients/1
  def show
    api_render(@host)
  end

  # POST /api/clients/1/backup
  def backup
    job = @host.job_templates.enabled.backup.find(params[:job_id])

    if job.backup_now
      message = 'Job is scheduled for backup'
    else
      message = 'Job can not be scheduled'
    end

    render json: { message: message }, status: :ok
  end

  # POST /api/clients/1/restore
  def restore
    fileset = @host.client.file_sets.find(params[:fileset_id])
    location = params[:location].blank? ? '/tmp/bacula_restore' : params[:location]

    if @host.restore(fileset.id, location)
      message = 'Restore is scheduled'
    else
      message = 'Restore not scheduled'
    end

    render json: { message: message }, status: :ok
  end

  private

  def fetch_host
    @host = current_api_user.hosts.in_bacula.find(params[:id])
  end

  def require_non_blocked_client
    if @host.blocked?
      message = 'Client is disabled by admins'
      render json: { message: message }, status: :ok
    end
  end
end

class Api::V1::ClientsController < Api::BaseController
  before_action :require_api_login

  # GET /api/clients
  def index
    hosts = current_api_user.hosts.in_bacula

    api_render(hosts)
  end

  # GET /api/clients/1
  def show
    host = current_api_user.hosts.in_bacula.find(params[:id])

    api_render(host)
  end

  # POST /api/clients/1/backup
  def backup
    host = current_api_user.hosts.in_bacula.find(params[:id])
    job = host.job_templates.enabled.backup.find(params[:job_id])

    if job.backup_now
      message = 'Job is scheduled for backup'
    else
      message = 'Job can not be scheduled'
    end

    render json: { message: message }, status: :ok
  end

  # POST /api/clients/1/restore
  def restore
    host = current_api_user.hosts.in_bacula.find(params[:id])
    fileset = host.client.file_sets.find(params[:fileset_id])
    location = params[:location].blank? ? '/tmp/bacula_restore' : params[:location]

    if host.restore(fileset.id, location)
      message = 'Restore is scheduled'
    else
      message = 'Restore not scheduled'
    end

    render json: { message: message }, status: :ok
  end
end

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
end

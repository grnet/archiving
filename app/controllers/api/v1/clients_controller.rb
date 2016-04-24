class Api::V1::ClientsController < Api::BaseController
  before_action :require_api_login

  # GET /api/clients
  def index
    hosts = current_api_user.hosts.in_bacula

    api_render(hosts)
  end
end

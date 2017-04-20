class Api::V1::Admin::ClientsController < Api::BaseController
  before_action :require_api_admin_login

  # GET /api/admin/clients/unverified
  def unverified
    hosts = Host.unverified

    admin_api_render(hosts)
  end

  private

  def require_api_admin_login
    if !current_api_user || !current_api_user.admin?
      head :forbidden
    end
  end

  # Wrapper method to simplify object rendering for api
  def admin_api_render(object)
    render json: object.to_json(for_admin_api: true)
  end
end



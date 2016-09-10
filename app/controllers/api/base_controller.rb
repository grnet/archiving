class Api::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token

  respond_to :json

  helper_method :current_api_user, :api_render

  rescue_from ActiveRecord::RecordNotFound do
    render json: {msg: 'resource not found'}, status: :not_found
  end

  # Returns a 403 forbidden header if there is no associated user with the provided token
  def require_api_login
    unless current_api_user
      head :forbidden
    end
  end

  protected

  # Fetches the current user based on the provided token
  def current_api_user
    @current_api_user ||=
      if token = request.env['HTTP_API_TOKEN'].presence
        User.where(enabled: true).find_by(token: token)
      end
  end

  # Wrapper method to simplify object rendering for api
  def api_render(object)
    render json: object.to_json(for_api: true)
  end
end

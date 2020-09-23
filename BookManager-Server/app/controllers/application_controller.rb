# frozen_string_literal: true

class ApplicationController < ActionController::API
  def jwt_authenticate
    jwt_authenticator = JwtAuthenticator.new
    result_hash = jwt_authenticator.jwt_authenticate(request)
    if result_hash[:is_auth_success]
      @current_user = result_hash[:current_user]
    else
      render_failed_response(401, result_hash[:message])
    end
  end

  def current_user
    @current_user ||= @current_user
  end

  def render_success_response(status, result)
    render json: { status: status, result: result }
  end

  def render_failed_response(status, error)
    render json: { status: status, error: error }
  end
end

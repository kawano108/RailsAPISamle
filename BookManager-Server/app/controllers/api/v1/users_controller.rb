# frozen_string_literal: true

class Api::V1::UsersController < ApplicationController
  before_action :jwt_authenticate, except: %i(login sign_up)

  def login
    login_user = User.find_by(email: params[:email])
    return render_failed_response(400, I18n.t('invalid_email')) unless login_user

    if login_user.authenticate(params[:password])
      render_success_response(200, { email: login_user.email,
                                     token: JwtClient.generate_token(login_user.id) })
    else
      render_failed_response(401, I18n.t('invalid_password'))
    end
  end

  def sign_up
    created_user = User.new(user_params)
    if created_user.save
      render_success_response(200, { email: created_user.email,
                                     token: JwtClient.generate_token(created_user.id) })
    else
      render_failed_response(400, created_user.errors.full_messages)
    end
  end

  private

  def user_params
    params.permit(:email, :password)
  end
end

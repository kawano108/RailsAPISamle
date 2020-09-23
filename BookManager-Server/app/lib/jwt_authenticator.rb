# frozen_string_literal: true

class JwtAuthenticator
  # モック化しやすようにクラスを切り出して認証を行っています。
  def jwt_authenticate(request)
    result_hash = { is_auth_success: false, current_user: nil, message: nil }

    fetched_token = get_bearer_token_from_headers(request)
    return result_hash.merge({ message: '認証できません。トークンが未設定です。' }) unless fetched_token

    decoded_token = JwtClient.decode_token(fetched_token)
    return result_hash.merge({ message: '認証できません。不正なトークンです。' }) unless decoded_token

    current_user = User.find_by(id: decoded_token['user_id'])
    return result_hash.merge({ message: '認証できません。登録を確認できませんでした。' }) unless current_user

    result_hash.merge({ is_auth_success: true, current_user: current_user })
  end

  def get_bearer_token_from_headers(request)
    return nil if request.headers['Authorization'].blank?

    scheme, token = request.headers['Authorization'].split(' ')
    scheme == 'Bearer' ? token : nil
  end
end

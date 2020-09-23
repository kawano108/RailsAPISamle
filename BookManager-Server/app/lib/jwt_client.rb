# frozen_string_literal: true

require 'jwt'
require 'logger'

class JwtClient
  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s

  def self.generate_token(user_id)
    payload = { user_id: user_id, exp: 1.month.from_now.to_i } # 1ヶ月 }
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def self.decode_token(token)
    JWT.decode(token,
               SECRET_KEY,
               true,
               algorithm: 'HS256').first
  rescue JWT::DecodeError, JWT::VerificationError, JWT::InvalidIatError => e
    # decodeに失敗した場合も401を返したいため、nilを返すことでjwt_authenticateのunlessに引っかけて401がrenderされるようにしています。
    Logger.new(STDOUT).error(I18n.t('errors.messages.failed_to_decode', errors: e))
    nil
  end
end

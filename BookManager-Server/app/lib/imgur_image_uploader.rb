# frozen_string_literal: true

require 'logger'

class ImgurImageUploader
  def self.upload_image(image)
    http_client = HTTPClient.new
    response = http_client.post(ENV['IMGUR_ENDPOINT'],
                                { image: image },
                                { Authorization: "Client-ID #{ENV['IMGUR_CLIENT_ID']}" })
    result_hash = JSON.parse(response.body)
    unless result_hash['success']
      Logger.new(STDOUT).error(I18n.t('errors.messages.failed_to_image_upload'))
      raise I18n.t('errors.messages.failed_to_image_upload')
    end
    result_hash.dig('data', 'link')
  end
end

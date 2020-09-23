# frozen_string_literal: true

class Book < ApplicationRecord
  before_save :convert_image

  belongs_to :user
  validates :name, presence: true

  def convert_image
    self.image = ImgurImageUploader.upload_image(image) if image.present?
  end
end

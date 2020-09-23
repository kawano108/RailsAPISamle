# frozen_string_literal: true

class User < ApplicationRecord
  before_save { email.downcase! }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  validates :email, presence: true,
                    uniqueness: { case_sensitive: true },
                    format: { with: VALID_EMAIL_REGEX },
                    length: { minimum: 6 }
  validates :password, presence: true, length: { minimum: 6 }

  has_secure_password
  has_many :books
end

# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }

    trait :with_45th_books do
      after(:create) { |user| create_list(:book, 45, user: user) }
    end
  end
end

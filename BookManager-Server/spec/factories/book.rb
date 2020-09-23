# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :book do
    name { Faker::Book.title }
    image { 'https://i.imgur.com/tdWnPfG.png' }
    price { Faker::Number.number(digits: 4) }
    purchase_date { Faker::Date.backward.to_s }

    association :user, factory: :user
  end
end

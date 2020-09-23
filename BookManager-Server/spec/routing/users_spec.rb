# frozen_string_literal: true

require 'rails_helper'

# 参考：https://relishapp.com/rspec/rspec-rails/v/2-4/docs/routing-specs/route-to-matcher
RSpec.describe Api::V1::UsersController, type: :routing do
  describe 'Users' do
    it 'routes to users#login' do
      expect(post: 'api/v1/login').to route_to('api/v1/users#login', format: 'json')
    end

    it 'routes to users#sign_up' do
      expect(post: 'api/v1/sign_up').to route_to('api/v1/users#sign_up', format: 'json')
    end
  end
end

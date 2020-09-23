# frozen_string_literal: true

require 'rails_helper'

# 参考：https://relishapp.com/rspec/rspec-rails/v/2-4/docs/routing-specs/route-to-matcher
RSpec.describe Api::V1::BooksController, type: :routing do
  describe 'Books' do
    it 'routes to books#index' do
      expect(get: 'api/v1/books').to route_to('api/v1/books#index', format: 'json')
    end

    it 'routes to books#create' do
      expect(post: 'api/v1/books').to route_to('api/v1/books#create', format: 'json')
    end

    it 'routes to books#update' do
      expect(put: 'api/v1/books/1').to route_to('api/v1/books#update', id: '1', format: 'json')
    end
  end
end

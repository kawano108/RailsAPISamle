# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authenticate', type: :request do
  describe '認証' do
    subject do
      get '/api/v1/books', params: request_params, headers: { Authorization: "Bearer #{token}" }
      JSON.parse(response.body)
    end
    before do
      allow(ImgurImageUploader).to receive(:upload_image).and_return(imgur_url)
      create(:user, :with_45th_books)
    end
    let(:request_params) { { limit: 20, page: 1 } }
    let(:imgur_url) { 'https://i.imgur.com/tdWnPfG.png' }

    context 'トークンの認証が通った時' do
      let(:token) { JwtClient.generate_token(User.first.id) }
      it 'レスポンスにステータス200が入っていること' do
        expect(subject['status']).to eq(200)
      end
    end

    context 'リクエストヘッダーにトークンが含まれない時' do
      let(:token) { nil }
      it 'レスポンスに401が入っていること' do
        expect(subject['status']).to eq(401)
      end
    end

    context 'トークンの形式が不正な時。([ヘッダー][ペイロード][署名]の形式ではなく「hoge」みたいな適当な文字列が渡された時)' do
      let(:token) { 'hoge' }
      it 'レスポンスに401が入っていること' do
        expect(subject['status']).to eq(401)
      end
    end

    context 'トークンの形式は正しいが、ペイロードから取得したuser_idが登録済みユーザーと合致しなかった時' do
      let(:token) { JwtClient.generate_token(User.all.count + 1) }
      it 'レスポンスに401が入っていること' do
        expect(subject['status']).to eq(401)
      end
    end
  end
end

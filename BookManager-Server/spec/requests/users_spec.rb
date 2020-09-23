# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'POST/sign_up' do
    subject do
      post '/api/v1/sign_up', params: request_params
      JSON.parse(response.body)
    end

    context 'パラメータが正しい時' do
      let(:request_params) { attributes_for(:user) }
      it 'レスポンスにステータス200が入っていること' do
        expect(subject['status']).to eq(200)
      end
      it 'レスポンスに正しいトークンが入ってること' do
        expect(subject['result']['token']).to eq(JwtClient.generate_token(User.first.id))
      end
      it 'レスポンスに正しいメールアドレスが入っていること' do
        expect(subject['result']['email']).to eq(request_params[:email])
      end
      it 'DBにユーザーが登録されること' do
        expect { subject }.to change { User.count }.by(1)
      end
    end

    context '登録済みのemailをパラメータにした時' do
      let(:request_params) { attributes_for(:user) }
      before { User.create(request_params) }
      it 'ステータス400を返すこと' do
        expect(subject['status']).to eq(400)
      end
    end
  end

  describe 'POST/login' do
    subject do
      post '/api/v1/login', params: request_params
      JSON.parse(response.body)
    end
    before { User.create(request_params) }
    let(:request_params) { attributes_for(:user) }

    context 'パラメータが正しい時' do
      it 'レスポンスにステータス200が入っていること' do
        expect(subject['status']).to eq(200)
      end
      it 'レスポンスに正しいトークンが入ってること' do
        expect(subject['result']['token']).to eq(JwtClient.generate_token(User.first.id))
      end
      it 'レスポンスに正しいメールアドレスが入っていること' do
        expect(subject['result']['email']).to eq(request_params[:email])
      end
    end

    context '登録済みユーザーにパラメータのemailが存在しなかった時' do
      it 'レスポンスにステータス400が入っていること' do
        request_params[:email] = ''
        expect(subject['status']).to eq(400)
      end
    end

    context 'パスワードで認証できなかった時' do
      it 'レスポンスにステータス401が入っていること' do
        request_params[:password] = ''
        expect(subject['status']).to eq(401)
      end
    end
  end
end

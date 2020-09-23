# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_secure_password }
  it { is_expected.to have_many(:books) }

  describe 'email' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_length_of(:email).is_at_least(6) }

    context '形式チェック' do
      it 'コンマ以外が挿入された場合' do
        expect(build(:user, email: 'test@co,jp')).not_to be_valid
      end
      it 'コンマが複数挿入された場合' do
        expect(build(:user, email: 'test@co..jp')).not_to be_valid
      end
    end

    # it { is_expected.to validate_uniqueness_of(:email) }だとbefore_saveの際にエラーが出るためshoulda_matchers無しでテストしています。
    context '重複チェック' do
      let(:first_user) { create(:user) }
      it 'メールアドレスが重複したときは無効' do
        expect(first_user.dup).not_to be_valid
      end
    end

    context 'downcase' do
      let(:email) { 'TEST@CO.JP' }
      let!(:user) { create(:user, email: email) }
      it 'downcaseに変換されること' do
        expect(user.reload.email).to eq 'test@co.jp'
      end
    end
  end

  describe 'password' do
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(6) }
  end
end

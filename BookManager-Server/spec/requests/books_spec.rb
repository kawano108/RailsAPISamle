# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Books', type: :request do
  # ユーザー作成後じゃないとUser.firstを取得できないため、beforeでユーザー作成後に使用してください。
  shared_context '認証スキップ' do
    let(:dummy_current_user) { User.first }
    let(:jwt_authenticator_double) { double(JwtAuthenticator) }
    before do
      allow(JwtAuthenticator).to receive(:new).and_return(jwt_authenticator_double)
      allow(jwt_authenticator_double).to receive(:jwt_authenticate).and_return({ is_auth_success: true,
                                                                                 current_user: dummy_current_user,
                                                                                 message: nil })
    end
  end

  # テストではImgurApiにリクエストを送らないようにするため用意しています。
  shared_context 'Imgurスキップ' do
    let(:imgur_url) { 'https://i.imgur.com/tdWnPfG.png' }
    before { allow(ImgurImageUploader).to receive(:upload_image).and_return(imgur_url) }
  end

  describe 'GET/books' do
    subject do
      get '/api/v1/books', params: request_params
      JSON.parse(response.body)
    end
    include_context 'Imgurスキップ'

    context '正常系', hoge: true do
      before do
        # 複数のユーザーが書籍を登録している状態を再現するために3回ユーザーの作成と書籍データの投入を行っています。
        create(:user, :with_45th_books)
        create(:user, :with_45th_books)
        create(:user, :with_45th_books)
      end
      include_context '認証スキップ'

      context '書籍数45件、limit20件, page1の場合' do
        let(:request_params) { { limit: 20, page: 1 } }
        it '通信に成功すること' do
          expect(subject.dig('status')).to eq(200)
        end
        it '20件取得できること' do
          expect(subject.dig('result').count).to eq(20)
          expect(subject.dig('limit')).to eq(20)
        end
        it 'オフセットが正しいこと' do
          fetched_book_id_list = subject.dig('result').map { |x| x['id'] }
          expect(fetched_book_id_list).to include(1..20)
        end
        it 'ページの計算が正しいこと' do
          expect(subject.dig('total_count')).to eq(45)
          expect(subject.dig('total_page')).to eq(3)
          expect(subject.dig('current_page')).to eq(1)
        end
      end

      context '書籍数45件、limit5件, page2の場合' do
        let(:request_params) { { limit: 5, page: 2 } }

        it '5件取得できること' do
          expect(subject.dig('result').count).to eq(5)
          expect(subject.dig('limit')).to eq(5)
        end
        it 'オフセットが正しいこと' do
          fetched_book_id_list = subject.dig('result').map { |x| x['id'] }
          expect(fetched_book_id_list).to include(6..10)
        end
        it 'ページの計算が正しいこと' do
          expect(subject.dig('total_count')).to eq(45)
          expect(subject.dig('total_page')).to eq(9)
          expect(subject.dig('current_page')).to eq(2)
        end
      end

      context '書籍数45件,limit、pageのパラメータが存在しない場合' do
        let(:request_params) { { limit: nil, page: nil } }

        it '1ページ目を20件取得できること' do
          expect(subject.dig('current_page')).to eq(1)
          fetched_book_id_list = subject.dig('result').map { |x| x['id'] }
          expect(fetched_book_id_list).to include(1..20)
        end
      end
    end

    context '異常系' do
      context '書籍が1件も存在しない時' do
        before { create(:user) }
        include_context '認証スキップ'
        let(:request_params) { { limit: 20, page: 1 } }
        it 'ステータス400を返すこと' do
          expect(subject.dig('status')).to eq(400)
        end
      end

      context '存在しないページをリクエストした時' do
        before { create(:user, :with_45th_books) }
        include_context '認証スキップ'
        let(:request_params) { { limit: 20, page: 10 } }
        it 'ステータス400を返すこと' do
          expect(subject.dig('status')).to eq(400)
        end
      end
    end
  end

  describe 'POST/books' do
    subject do
      post '/api/v1/books', params: request_params
      JSON.parse(response.body)
    end
    before { create(:user) }
    include_context '認証スキップ'

    context 'パラメータが正しい時' do
      include_context 'Imgurスキップ'
      let(:request_params) { attributes_for(:book) }

      it 'ステータス200が返ること' do
        expect(subject.dig('status')).to eq(200)
      end
      it '登録した書籍の内容を返すこと' do
        expect(subject.dig('result', 'name')).to eq(request_params[:name])
        expect(subject.dig('result', 'image')).to eq(imgur_url)
        expect(subject.dig('result', 'price')).to eq(request_params[:price])
        expect(subject.dig('result', 'purchase_date')).to eq(request_params[:purchase_date])
      end
      it 'DBに本が登録されること' do
        expect { subject }.to change { Book.count }.by(1)
      end
    end

    context 'Imgurで変換できないパラメータを受け取った場合' do
      let(:request_params) { attributes_for(:book, image: 'hoge') }
      it 'エラーが起きること' do
        expect { ImgurImageUploader.upload_image 'hoge' }.to raise_error RuntimeError
      end

      it 'ステータス400が返ること' do
        expect(subject.dig('status')).to eq(400)
      end
    end
  end

  describe 'PUT/books/:id' do
    subject do
      put "/api/v1/books/#{id}", params: request_params
      JSON.parse(response.body)
    end
    include_context 'Imgurスキップ'
    before do
      create(:book)
      create(:book)
    end
    include_context '認証スキップ'
    let(:request_params) { attributes_for(:book) }

    context 'パラメータが正しい時' do
      let(:id) { Book.first.id }
      it 'ステータス200が返ること' do
        expect(subject.dig('status')).to eq(200)
      end
      it '登録した書籍の内容を返すこと' do
        expect(subject.dig('result', 'name')).to eq(request_params[:name])
        expect(subject.dig('result', 'image')).to eq(imgur_url)
        expect(subject.dig('result', 'price')).to eq(request_params[:price])
        expect(subject.dig('result', 'purchase_date')).to eq(request_params[:purchase_date])
      end
      it 'DBの登録内容が更新されていること' do
        subject
        expect(Book.first.name).to eq(request_params[:name])
        expect(Book.first.image).to eq(imgur_url)
        expect(Book.first.price).to eq(request_params[:price])
        expect(Book.first.purchase_date.to_s).to eq(request_params[:purchase_date].to_s)
      end
    end

    context 'ログインユーザーに紐づかない書籍のidが指定された時' do
      let(:id) { Book.first.id + 1 }
      it 'ステータス400を返すこと' do
        expect(subject.dig('status')).to eq(400)
      end
      it 'リクエストidの書籍が更新されていないこと' do
        # Bookオブジェクトを指定してchangeのマッチャーをかけると変更があったと判定されてしまいます。原因が分かったらテストを修正してください。
        expect { subject }.not_to change(Book.find(id), :name)
        expect { subject }.not_to change(Book.find(id), :image)
        expect { subject }.not_to change(Book.find(id), :price)
        expect { subject }.not_to change(Book.find(id), :purchase_date)
      end
    end
  end
end

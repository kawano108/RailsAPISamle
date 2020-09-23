Rails.application.routes.draw do
  # namespaceを利用することで、 /api/v1/each_api 形式のrouting設定を行っています。
  namespace :api, format: 'json' do
    namespace :v1 do
      # UsersController
      post '/login', to: 'users#login'
      post '/sign_up', to: 'users#sign_up'

      # BooksController
      resources :books, only: %i(index create update)
    end
  end
end

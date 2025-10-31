require 'sidekiq/web'
Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(username, ENV.fetch('SIDEKIQ_USER', 'admin')) &
  ActiveSupport::SecurityUtils.secure_compare(password, ENV.fetch('SIDEKIQ_PASSWORD', 'secret'))
end
Rails.application.routes.draw do
  resources :applications, param: :token, only: [:create, :show, :index, :update, :destroy] do
    resources :chats, only: [:create, :index, :show], param: :number do
      resources :messages, only: [:create, :index, :show], param: :number do
        collection do
          get :search
        end
      end
    end
  end
  mount Sidekiq::Web => '/sidekiq'
end

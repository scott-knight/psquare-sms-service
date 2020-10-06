require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  namespace :v1 do
    resources :sms_messages, only: %w[index create show] do
      member do
        post :resend
      end
      collection do
        post :delivery_status
      end
    end
  end
end

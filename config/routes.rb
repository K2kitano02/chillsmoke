Rails.application.routes.draw do
  devise_for :users
  # ISSUE-21/22/23: 1ユーザー1設定。初期設定 new/create、編集 edit/update
  resource :user_setting, only: %i[new create edit update]
  # Plan.md: ログイン後の本画面。表示の中身は ISSUE-53 以降で拡張
  get "dashboard", to: "dashboard#index", as: :dashboard
  root "home#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end

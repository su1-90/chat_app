Rails.application.routes.draw do
  root "home#index"

  devise_for :users
  resources :friendships, only: [:index, :create, :update, :destroy]
  get "up" => "rails/health#show", as: :rails_health_check
end

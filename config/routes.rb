Rails.application.routes.draw do
  # get 'users/index'
  root "home#index"

  devise_for :users
  resources :users, only: [:index]
  resources :friendships, only: [:index, :create, :update, :destroy]
  get "up" => "rails/health#show", as: :rails_health_check
end

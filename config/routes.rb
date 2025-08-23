Rails.application.routes.draw do
  # get 'users/index'
  root "home#index"

  devise_for :users
  resources :users, only: [:index]
  resources :friendships, only: %i[index create update destroy] do
    collection do
      get :accepted
    end
  end
  get "up" => "rails/health#show", as: :rails_health_check
end

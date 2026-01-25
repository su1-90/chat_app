Rails.application.routes.draw do
  get 'messages/create'
  root 'home#index'

  devise_for :users
  resources :users, only: [:index]

  # 友達申請の管理
  resources :friend_requests, only: %i[create update destroy]

  # 友達関係の管理
  resources :friendships, only: %i[index destroy]

  # チャットルームとメッセージの管理
  # messagesのdestroyは「誰が消せる？」の仕様が固まってから
  resources :chat_rooms, only: %i[index create show] do
    resources :messages, only: %i[create]
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end

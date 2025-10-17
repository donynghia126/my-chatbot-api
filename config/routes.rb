# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # --- Routes cũ ---
      post 'chat', to: 'chat#create'
      resources :users, only: [:create]
      post 'login', to: 'authentication#login'
      resources :conversations, only: [:index, :show, :update, :destroy] 
      resource :profile, only: [:show, :update], controller: 'profile'

      # === THÊM ROUTE MỚI CHO MIND MAP ===
      post 'mind_map', to: 'mind_maps#create'
      post 'socratic_question', to: 'socratic_questions#create' 

      # === KHU VỰC ROUTE CHO ADMIN ===
      namespace :admin do
        resources :users, only: [:index, :update, :destroy] do
          resources :conversations, only: [:index], controller: 'admin_conversations'
        end
        resources :conversations, only: [:show], controller: 'conversations'
      end
    end
  end
  get '/health', to: 'application#health'
end

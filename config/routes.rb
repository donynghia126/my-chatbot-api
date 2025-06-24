# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # --- Routes cũ ---
      post 'chat', to: 'chat#create'
      resources :users, only: [:create]
      post 'login', to: 'authentication#login'

      resources :conversations, only: [:index, :show, :update, :destroy] 
        # === THÊM KHU VỰC ROUTE CHO ADMIN ===
      namespace :admin do
        # SỬA LẠI KHỐI NÀY
        resources :users, only: [:index, :update, :destroy] do
          # Lồng conversations vào trong users để tạo route
          # GET /api/v1/admin/users/:user_id/conversations
          resources :conversations, only: [:index], controller: 'admin_conversations'
        end
          # để lấy chi tiết một cuộc hội thoại cụ thể
          resources :conversations, only: [:show], controller: 'conversations'
      end
      resource :profile, only: [:show, :update], controller: 'profile'

    end
    
  end
end
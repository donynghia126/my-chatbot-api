# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # --- Routes cũ ---
      post 'chat', to: 'chat#create'
      resources :users, only: [:create]
      post 'login', to: 'authentication#login'

      # === THÊM ROUTES MỚI CHO CONVERSATIONS ===
      #
      # GET /api/v1/conversations -> Lấy danh sách các cuộc hội thoại của user
      # GET /api/v1/conversations/:id -> Lấy toàn bộ tin nhắn của 1 cuộc hội thoại
      #
      resources :conversations, only: [:index, :show, :update, :destroy] 
        # === THÊM KHU VỰC ROUTE CHO ADMIN ===
      namespace :admin do
        # GET /api/v1/admin/users -> Lấy danh sách tất cả user (chỉ admin mới được gọi)
        resources :users, only:  [:index, :update, :destroy]
      end

    end
    
  end
end
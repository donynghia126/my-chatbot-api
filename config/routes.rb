Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Khi có POST request tới /api/v1/chat, sẽ gọi action 'create' trong ChatController
      post 'chat', to: 'chat#create'
      
      # "Sếp" cũng có thể đặt tên action là 'converse' hay gì đó "kêu" hơn nếu muốn
    end
  end


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end

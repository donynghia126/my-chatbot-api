# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Đảm bảo địa chỉ này CHÍNH XÁC là nơi React app của sếp đang chạy
    origins 'http://localhost:5173' # Hoặc ENV.fetch('CORS_ALLOWED_ORIGINS', 'http://localhost:5173')

    resource '*', # Cho phép tất cả các đường dẫn
      headers: :any, # Cho phép tất cả các loại header
      # QUAN TRỌNG: Phải có :options ở đây!
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
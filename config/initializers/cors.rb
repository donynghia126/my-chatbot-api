# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Lấy danh sách các origin được phép từ biến môi trường.
    # Nếu không có, mặc định sẽ cho phép các địa chỉ phổ biến khi dev (localhost và 127.0.0.1)
    allowed_origins = ENV.fetch('CORS_ALLOWED_ORIGINS', 'http://localhost:5173,http://127.0.0.1:5173')

    # Tách chuỗi thành mảng các origin và loại bỏ khoảng trắng thừa
    origins allowed_origins.split(',').map { |origin| origin.strip }

    resource '*',
      headers: :any,
      # Quan trọng: Phải cho phép tất cả các method, bao gồm cả OPTIONS (preflight request)
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
# Rails.application.config.middleware.insert_before 0, Rack::Cors do

# allow do

# # Đảm bảo địa chỉ này CHÍNH XÁC là nơi React app của sếp đang chạy

# origins 'http://localhost:5173' # Hoặc ENV.fetch('CORS_ALLOWED_ORIGINS', 'http://localhost:5173')



# resource '*', # Cho phép tất cả các đường dẫn

# headers: :any, # Cho phép tất cả các loại header

# # QUAN TRỌNG: Phải có :options ở đây!

# methods: [:get, :post, :put, :patch, :delete, :options, :head]

# end

# end
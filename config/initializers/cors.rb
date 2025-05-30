# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Dòng này sẽ đọc giá trị từ biến môi trường CORS_ALLOWED_ORIGINS trên Render.
    # Nếu không có biến đó (ví dụ khi chạy ở local mà không set .env),
    # nó sẽ dùng 'http://localhost:5173,http://127.0.0.1:5173' làm giá trị mặc định.
    # Thêm 127.0.0.1 để chắc chắn khi dev local.
    # .split(',') để cho phép nhiều origin, cách nhau bằng dấu phẩy trong ENV VAR.
    allowed_origins = ENV.fetch('CORS_ALLOWED_ORIGINS', 'http://localhost:5173,http://127.0.0.1:5173')
    origins allowed_origins.split(',').map { |origin| origin.strip } # Tách chuỗi thành mảng và loại bỏ khoảng trắng thừa

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head] # :options đã có, rất tốt!
  end
end
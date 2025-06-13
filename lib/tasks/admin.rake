# lib/tasks/admin.rake
namespace :users do
  desc "Grant admin privileges to a user by email"
  task grant_admin: :environment do
    # Lấy email từ biến môi trường mà mình sẽ đặt trên Render
    email = ENV['EMAIL']

    unless email
      puts "Lỗi: Vui lòng cung cấp email bằng cách chạy: rake users:grant_admin EMAIL=your_email@example.com"
      next
    end

    user = User.find_by(email: email)

    if user
      # Cập nhật quyền admin cho user
      user.update!(admin: true)
      puts "Thành công! Đã trao quyền admin cho user: #{user.email}"
    else
      puts "Không tìm thấy user với email: #{email}"
    end
  end
end
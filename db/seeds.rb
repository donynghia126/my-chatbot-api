# db/seeds.rb

# --- Logic phong chức admin ---
# Lấy email admin từ biến môi trường để an toàn,
# nếu không có thì fallback về email của sếp
admin_email = ENV.fetch('ADMIN_EMAIL', 'donynghia126@gmail.com')

admin_user = User.find_by(email: admin_email)

if admin_user
  admin_user.update!(admin: true)
  puts "SUCCESS: Granted admin rights to #{admin_user.email}"
else
  puts "WARNING: Admin user with email #{admin_email} not found. Please register this user first."
end

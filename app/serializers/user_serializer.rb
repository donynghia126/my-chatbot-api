# app/serializers/user_serializer.rb
# Phiên bản có thể hiển thị URL của avatar

class UserSerializer < ActiveModel::Serializer
  # Thêm `include Rails.application.routes.url_helpers` để có thể dùng `url_for`
  include Rails.application.routes.url_helpers

  # Thêm :avatar_url vào danh sách thuộc tính
  attributes :id, :email, :first_name, :last_name, :admin, :created_at, :avatar_url

  # Định nghĩa phương thức để tạo ra URL
  def avatar_url
    # `object` ở đây chính là user đang được serialize
    # Nếu user có đính kèm avatar, thì tạo URL cho nó, nếu không thì trả về nil
    url_for(object.avatar) if object.avatar.attached?
  end
end

# app/serializers/user_serializer.rb
class UserSerializer < ActiveModel::Serializer
  # Liệt kê tất cả các thuộc tính muốn hiển thị ra ngoài, TRỪ password_digest
  attributes :id, :email, :first_name, :last_name, :admin, :created_at
end
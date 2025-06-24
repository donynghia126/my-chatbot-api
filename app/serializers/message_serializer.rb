# app/serializers/message_serializer.rb
# Đây là "nhà máy" chuyên đóng gói cho một tin nhắn
class MessageSerializer < ActiveModel::Serializer
  attributes :id, :role, :content
end
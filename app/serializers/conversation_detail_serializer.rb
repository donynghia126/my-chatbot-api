# app/serializers/conversation_detail_serializer.rb
# Phiên bản cuối cùng, đính kèm đầy đủ thông tin cần thiết

class ConversationDetailSerializer < ActiveModel::Serializer
  attributes :id, :title, :pinned, :user_id

  # Đính kèm object user (chủ nhân cuộc hội thoại)
  belongs_to :user

  # Đính kèm danh sách tin nhắn
  has_many :messages
end

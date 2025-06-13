# app/serializers/conversation_detail_serializer.rb
class ConversationDetailSerializer < ActiveModel::Serializer
  attributes :id, :title, :created_at
  has_many :messages

  # Định dạng cho các tin nhắn con
  class MessageSerializer < ActiveModel::Serializer
    attributes :id, :role, :content, :created_at
  end
end
# app/serializers/conversation_list_serializer.rb
class ConversationListSerializer < ActiveModel::Serializer
  attributes :id, :title, :updated_at
end
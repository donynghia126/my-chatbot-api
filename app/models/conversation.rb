# app/models/conversation.rb
class Conversation < ApplicationRecord
  belongs_to :user # Một Conversation thuộc về một User
  has_many :messages, dependent: :destroy # Một Conversation có nhiều Message
end

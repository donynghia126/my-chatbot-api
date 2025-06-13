# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :conversation # Một Message thuộc về một Conversation
end
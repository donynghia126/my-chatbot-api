# app/controllers/api/v1/admin/conversations_controller.rb
module Api
  module V1
    module Admin
      class ConversationsController < ApplicationController
        before_action :authenticate_request
        before_action :authorize_admin!

        # GET /api/v1/admin/conversations/:id
        def show
          # Tìm cuộc hội thoại trực tiếp bằng ID, không cần scope theo user
          conversation = Conversation.find(params[:id])

          # Dùng lại ConversationDetailSerializer để lấy cả tin nhắn
          render json: conversation, serializer: ConversationDetailSerializer, adapter: :json

        rescue ActiveRecord::RecordNotFound
          render json: { error: "Conversation not found" }, status: :not_found
        end
      end
    end
  end
end

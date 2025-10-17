# app/controllers/api/v1/admin/admin_conversations_controller.rb
module Api
  module V1
    module Admin
      class AdminConversationsController < ApplicationController
        before_action :authenticate_request
        before_action :authorize_admin!

        # GET /api/v1/admin/users/:user_id/conversations
        def index
          # Tìm user mục tiêu dựa vào :user_id từ URL
          target_user = User.find(params[:user_id])

          # Lấy tất cả các cuộc hội thoại của user đó
          conversations = target_user.conversations.order(updated_at: :desc)

          # Dùng lại ConversationListSerializer để hiển thị danh sách
          render json: conversations, each_serializer: ConversationListSerializer, adapter: :json

        rescue ActiveRecord::RecordNotFound
          render json: { error: "User not found" }, status: :not_found
        end
      end
    end
  end
end

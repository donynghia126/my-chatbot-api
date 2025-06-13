# app/controllers/api/v1/conversations_controller.rb
# Phiên bản đã được tinh chỉnh và hoàn thiện

module Api
  module V1
    class ConversationsController < ApplicationController
      # Yêu cầu "giấy thông hành" (token) cho tất cả các action
      before_action :authenticate_request
      
      # <<-- SỬA LỖI Ở ĐÂY -->>
      # Tự động chạy hàm `set_conversation` trước các action :show, :update, và :destroy
      # để tìm và gán @conversation, giúp code gọn hơn và tránh lặp lại.
      before_action :set_conversation, only: [:show, :update, :destroy]

      # GET /api/v1/conversations
      def index
        conversations = @current_user.conversations.order(updated_at: :desc)
        render json: conversations, each_serializer: ConversationListSerializer
      end

      # GET /api/v1/conversations/:id
      def show
        # Không cần tìm conversation nữa vì before_action đã làm
        render json: @conversation, serializer: ConversationDetailSerializer
      end

      # PUT/PATCH /api/v1/conversations/:id
      def update
        # Không cần tìm conversation nữa, dùng trực tiếp @conversation
        if @conversation.update(conversation_params)
          render json: @conversation, serializer: ConversationListSerializer
        else
          render json: { errors: @conversation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/conversations/:id
      def destroy
        # Không cần tìm conversation nữa, dùng trực tiếp @conversation
        @conversation.destroy
        head :no_content
      end

      private

      # Phương thức này sẽ được gọi bởi before_action
      def set_conversation
        # Tìm conversation phải thuộc về user đang đăng nhập
        @conversation = @current_user.conversations.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Conversation not found or permission denied' }, status: :not_found
      end

      # Strong params cho việc đổi tên, chỉ cho phép thuộc tính 'title'
      def conversation_params
        params.require(:conversation).permit(:title)
      end
    end
  end
end
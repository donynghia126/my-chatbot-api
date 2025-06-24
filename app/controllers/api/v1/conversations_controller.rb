# app/controllers/api/v1/conversations_controller.rb
# Phiên bản đã được nâng cấp để xử lý chức năng Ghim
module Api
  module V1
    class ConversationsController < ApplicationController
      before_action :authenticate_request
      before_action :set_conversation, only: [:show, :update, :destroy]

      # GET /api/v1/conversations
      def index
        # SỬA ĐỔI Ở ĐÂY: Sắp xếp theo `pinned` trước, rồi mới đến `updated_at`
        # `pinned: :desc` sẽ đưa các giá trị `true` (đã ghim) lên đầu.
        conversations = @current_user.conversations.order(pinned: :desc, updated_at: :desc)
        
        render json: conversations, each_serializer: ConversationListSerializer, adapter: :json
      end

      # GET /api/v1/conversations/:id
      def show
        render json: @conversation, serializer: ConversationDetailSerializer
      end

      # PUT/PATCH /api/v1/conversations/:id
      def update
        if @conversation.update(conversation_params)
          # THÊM adapter: :json vào đây để ép nó trả về JSON phẳng
          render json: @conversation, serializer: ConversationListSerializer, adapter: :json
        else
          render json: { errors: @conversation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/conversations/:id
      def destroy
        @conversation.destroy
        head :no_content
      end

      private

      def set_conversation
        @conversation = @current_user.conversations.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Conversation not found or permission denied' }, status: :not_found
      end

      # Strong params cho việc cập nhật, giờ đây cho phép cả `title` và `pinned`
      def conversation_params
        # SỬA ĐỔI Ở ĐÂY: Thêm `:pinned` vào danh sách cho phép
        params.require(:conversation).permit(:title, :pinned)
      end
    end
  end
end
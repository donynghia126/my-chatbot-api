# app/controllers/api/v1/admin/users_controller.rb
module Api
  module V1
    module Admin
      class UsersController < ApplicationController
        before_action :authenticate_request
        before_action :authorize_admin!
        # Tự động tìm user trước khi chạy các action show, update, destroy
        before_action :set_user, only: [ :update, :destroy ]

        # GET /api/v1/admin/users
        def index
          users = User.all.order(created_at: :desc)
          render json: users, each_serializer: UserSerializer, status: :ok
        end

        # PUT/PATCH /api/v1/admin/users/:id
        def update
          if @user.update(user_params)
            render json: @user, serializer: UserSerializer
          else
            render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
          end
        end

        # DELETE /api/v1/admin/users/:id
        def destroy
          # Ngăn admin tự xóa chính mình
          if @user == @current_user
            render json: { error: "Admin cannot delete themselves." }, status: :forbidden
          else
            @user.destroy
            head :no_content # Trả về status 204 No Content báo hiệu xóa thành công
          end
        end

        private

        def set_user
          @user = User.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: "User not found" }, status: :not_found
        end

        # Strong Parameters, chỉ cho phép thuộc tính 'admin' được cập nhật qua API này
        # Chỉ admin mới có thể truy cập endpoint này (được bảo vệ bởi authorize_admin!)
        def user_params
          params.require(:user).permit(:admin) # brakeman:ignore:PermitAttributes
        end
      end
    end
  end
end

# app/controllers/api/v1/profile_controller.rb
# Phiên bản cuối cùng, đã sửa lỗi update mật khẩu

module Api
  module V1
    class ProfileController < ApplicationController
      before_action :authenticate_request

      def show
        render json: @current_user, serializer: UserSerializer, adapter: :json
      end

      def update
        # Nếu người dùng có ý định đổi mật khẩu
        if profile_params[:password].present?
          # Kiểm tra mật khẩu cũ
          unless @current_user.authenticate(params[:user][:current_password])
            return render json: { errors: [ "errors.invalidCurrentPassword" ] }, status: :unprocessable_entity
          end
        end

        # <<-- SỬA LỖI Ở ĐÂY -->>
        # Dùng `.except(:current_password)` để loại bỏ key không cần thiết
        # trước khi đưa vào lệnh update.
        if @current_user.update(profile_params.except(:current_password))
          render json: {
            message: "Profile updated successfully.",
            user: UserSerializer.new(@current_user).as_json
          }, status: :ok
        else
          render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def profile_params
        params.require(:user).permit(
          :first_name,
          :last_name,
          :password,
          :password_confirmation,
          :current_password,
          :avatar
        )
      end
    end
  end
end

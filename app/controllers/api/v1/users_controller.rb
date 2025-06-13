# app/controllers/api/v1/users_controller.rb
module Api
  module V1
    class UsersController < ApplicationController
      # POST /api/v1/users (để đăng ký user mới)
      def create
        user = User.new(user_params)

        if user.save
          # Đăng ký thành công
          # Tạm thời mình chỉ trả về một thông báo.
          # Sau này, mình có thể muốn trả về cả thông tin user (trừ password_digest) 
          # hoặc tự động đăng nhập và trả về token ngay tại đây.
          render json: { message: 'User created successfully. Please log in.' }, status: :created 
        else
          # Đăng ký thất bại (do lỗi validations trong model User)
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      # Strong Parameters: Chỉ cho phép các tham số an toàn được truyền vào khi tạo User
      def user_params
        params.require(:user).permit(
          :first_name, 
          :last_name, 
          :email, 
          :password, 
          :password_confirmation
          # Thêm các trường khác sếp đã thêm vào model User nếu có, ví dụ:
          # :phone_number, 
          # :date_of_birth
        )
      end
    end
  end
end
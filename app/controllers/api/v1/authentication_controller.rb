# app/controllers/api/v1/authentication_controller.rb
module Api
  module V1
    class AuthenticationController < ApplicationController
      # POST /api/v1/login
      def login
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          # Tạo token JWT
          hmac_secret = Rails.application.secret_key_base
          exp = Time.now.to_i + 24 * 3600 # Hết hạn sau 24 giờ
          payload = { user_id: user.id, exp: exp }
          token = JWT.encode(payload, hmac_secret, "HS256")

          # <<-- NÂNG CẤP Ở ĐÂY -->>
          # Dùng UserSerializer để tạo ra một object user nhất quán,
          # tự động bao gồm cả avatar_url và các trường khác.
          render json: {
            token: token,
            user: UserSerializer.new(user).as_json
          }, status: :ok
        else
          # Email không tồn tại hoặc mật khẩu sai
          render json: { error: "errors.invalidCredentials" }, status: :unauthorized
        end
      rescue StandardError => e
        Rails.logger.error "Login error: #{e.message}"
        render json: { error: "An unexpected error occurred during login." }, status: :internal_server_error
      end
    end
  end
end

# app/controllers/api/v1/authentication_controller.rb
module Api
  module V1
    class AuthenticationController < ApplicationController
      # Bỏ qua việc kiểm tra authenticity token cho API, vì mình sẽ dùng token JWT
      # skip_before_action :verify_authenticity_token # Dòng này không cần thiết nếu ApplicationController kế thừa từ ActionController::API

      # POST /api/v1/login
      def login
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          # Mật khẩu đúng, tạo token JWT
          # "Bí mật" để ký token, nên lưu ở ENV variable cho an toàn
          # Ví dụ: Rails.application.credentials.secret_key_base hoặc một key ngẫu nhiên mạnh khác
          # Tạm thời để dễ, mình dùng một chuỗi cố định (NHƯNG KHÔNG NÊN DÙNG CHO PRODUCTION THẬT)
          # Sếp NÊN tạo một biến môi trường mới ví dụ: JWT_SECRET_KEY và dùng ENV['JWT_SECRET_KEY']
          hmac_secret = Rails.application.secret_key_base # Dùng secret_key_base của Rails cho an toàn hơn là hardcode

          # Payload chứa thông tin mình muốn mã hóa vào token (ví dụ: user_id)
          # Thêm thời gian hết hạn cho token (ví dụ: 24 giờ kể từ bây giờ)
          exp = Time.now.to_i + 24 * 3600 # 24 hours
          payload = { user_id: user.id, exp: exp }

          token = JWT.encode(payload, hmac_secret, 'HS256')

          render json: { token: token, exp: Time.at(exp).iso8601, user_id: user.id, email: user.email, first_name: user.first_name,admin: user.admin }, status: :ok
        else
          # Email không tồn tại hoặc mật khẩu sai
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      rescue StandardError => e
        Rails.logger.error "Login error: #{e.message}"
        render json: { error: "An unexpected error occurred during login." }, status: :internal_server_error
      end

      # (Action logout có thể thêm sau này nếu cần cơ chế blacklist token)
      # def logout
      #   # Logic xử lý logout, ví dụ: thêm token vào blacklist
      #   render json: { message: 'Logged out successfully' }, status: :ok
      # end

      # Strong params không cần thiết ở đây vì mình lấy params[:email] và params[:password] trực tiếp
      # Nhưng nếu payload phức tạp hơn thì nên dùng
    end
  end
end
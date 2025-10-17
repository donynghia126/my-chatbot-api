# app/controllers/application_controller.rb
# Phiên bản đã được sửa lỗi cú pháp và ghi chú lại

class ApplicationController < ActionController::API
  # "Sếp" nhớ là mình đang kế thừa từ ActionController::API cho app API-only nhé

  # Phương thức này sẽ được các controller con (như ChatController, Admin::UsersController)
  # gọi thông qua `before_action` để kiểm tra và xác thực người dùng.
  def authenticate_request
    header = request.headers['Authorization']
    # Lấy token từ header, bỏ đi chữ "Bearer " ở đầu
    token = header.split(' ').last if header
    unless token
      render json: { errors: 'Token is missing' }, status: :unauthorized
      return # Dừng lại ngay nếu không có token
    end
    begin
      # Giải mã token để lấy payload (chứa user_id)
      decoded_token = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')
      # Tìm user dựa trên user_id trong token và gán vào biến instance @current_user
      # để các controller con có thể sử dụng
      @current_user = User.find(decoded_token[0]['user_id'])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      # Các lỗi giải mã token (hết hạn, sai chữ ký,...)
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  # <<-- SỬA LỖI: `private` được đặt ở đây, ngang cấp với các hàm -->>
  private

  # Hàm mới để kiểm tra quyền admin, sẽ được gọi bởi các controller dành riêng cho admin
  def authorize_admin!
    # Dùng `unless` để code gọn hơn
    # Nếu @current_user không tồn tại hoặc không phải là admin, thì báo lỗi
    unless @current_user&.admin?
      render json: { error: 'Not authorized' }, status: :forbidden # 403 Forbidden
    end
  end
  skip_before_action :verify_authenticity_token, only: [:health]

  def health
    render json: { status: 'OK', timestamp: Time.now.utc }, status: :ok
  end
end

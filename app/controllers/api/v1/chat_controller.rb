# app/controllers/api/v1/chat_controller.rb
require 'httparty'

module Api
  module V1
    class ChatController < ApplicationController
      # skip_before_action :verify_authenticity_token, if: -> { request.format.json? } # Đã comment/xóa ở bước trước

      GEMINI_API_ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

      def create
        chat_session_params = params[:chatSession] # Nhận mảng các tin nhắn từ React

        if chat_session_params.blank? || !chat_session_params.is_a?(Array)
          render json: { error: "Dữ liệu chat không hợp lệ!" }, status: :bad_request
          return
        end

        # Tin nhắn mới nhất của người dùng là phần tử cuối cùng của mảng
        # user_message = chat_session_params.last[:text] # Không cần thiết nữa nếu gửi cả session cho Gemini

        api_key = ENV['GEMINI_API_KEY']
        if api_key.blank?
          Rails.logger.error "GEMINI_API_KEY chưa được thiết lập trong ENV!"
          render json: { error: "Lỗi cấu hình phía server, sếp vui lòng thử lại sau." }, status: :internal_server_error
          return
        end

        # Chuẩn bị "contents" cho Gemini từ chat_session_params
        # Gemini muốn mỗi item trong contents có dạng { role: "user/model", parts: [{ text: "..." }] }
        gemini_contents = chat_session_params.map do |chat_item|
          {
            role: chat_item[:role], # React đã gửi đúng 'user' hoặc 'model'
            parts: [{ text: chat_item[:text] }]
          }
        end

        request_body = {
          contents: gemini_contents
          # "generationConfig": { ... }, # Sếp có thể thêm config nếu muốn
          # "safetySettings": [ ... ]
        }.to_json

        headers = { "Content-Type" => "application/json" }
        full_api_url = "#{GEMINI_API_ENDPOINT}?key=#{api_key}"

        begin
          response = HTTParty.post(full_api_url, body: request_body, headers: headers, timeout: 60)

          if response.success?
            parsed_response = response.parsed_response
            ai_text_parts = parsed_response.dig("candidates", 0, "content", "parts")
            
            if ai_text_parts && ai_text_parts.is_a?(Array) && ai_text_parts.first && ai_text_parts.first.key?("text")
              ai_reply = ai_text_parts.map { |part| part["text"] }.join("\n")
            else
              Rails.logger.error "Không tìm thấy nội dung text trong response từ Gemini: #{parsed_response}"
              ai_reply = "Gemini có phản hồi nhưng tôi không 'dịch' được nội dung."
            end
            render json: { reply: ai_reply }, status: :ok
          else
            Rails.logger.error "Lỗi từ Gemini API: Status #{response.code}, Body: #{response.body}"
            error_message = "Gemini đang 'bận' hoặc có lỗi (Code: #{response.code})."
            parsed_error = response.parsed_response rescue nil
            if parsed_error && parsed_error.dig("error", "message")
              error_message += " Chi tiết: #{parsed_error.dig("error", "message")}"
            end
            render json: { error: error_message }, status: response.code
          end
        rescue HTTParty::Error => e
          Rails.logger.error "Lỗi HTTParty khi gọi Gemini API: #{e.message}"
          render json: { error: "Không kết nối được tới Gemini." }, status: :service_unavailable
        rescue StandardError => e
          Rails.logger.error "Lỗi bất ngờ trong ChatController khi gọi Gemini: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render json: { error: "Server backend có lỗi khi nói chuyện với Gemini." }, status: :internal_server_error
        end
      end
    end
  end
end
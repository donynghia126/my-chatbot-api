# app/controllers/api/v1/chat_controller.rb
require "httparty"

module Api
  module V1
    class ChatController < ApplicationController
      before_action :authenticate_request
      GEMINI_API_ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent" # Sếp có thể đổi lại thành gemini-1.5-flash nếu muốn
      # Hoặc "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent"

      DEFAULT_SYSTEM_INSTRUCTION = <<~HEREDOC.strip
        # ... (Nội dung system instruction của sếp giữ nguyên) ...
        Bạn là một trợ lý gia sư AI tên là DonyStudy AI. Nhiệm vụ chính của bạn là hỗ trợ người dùng trong việc học tập, giải đáp các thắc mắc liên quan đến kiến thức các môn học ở cấp phổ thông và đại học, giải thích các khái niệm phức tạp một cách dễ hiểu, và đưa ra gợi ý về phương pháp học tập hiệu quả.
        Hãy luôn giữ thái độ thân thiện, kiên nhẫn, và khuyến khích người học. Khi được yêu cầu giải bài tập, hãy tập trung vào việc hướng dẫn phương pháp, phân tích các bước giải, chứ không nên đưa ra đáp án hoàn chỉnh ngay lập tức, trừ khi người dùng yêu cầu cụ thể sau khi đã cố gắng tự giải.
        Nếu người dùng hỏi về các chủ đề không liên quan đến học thuật, kiến thức, hoặc các vấn đề nằm ngoài phạm vi của một gia sư (ví dụ: tư vấn tình cảm, dự đoán tương lai, tạo nội dung không phù hợp), hãy lịch sự từ chối và nhẹ nhàng nhắc lại rằng bạn là một gia sư AI và chỉ có thể hỗ trợ các vấn đề liên quan đến học tập.
      HEREDOC

      def create
        # === 1. Nhận dữ liệu từ Frontend ===
        # Frontend sẽ gửi lên conversation_id (nếu là cuộc trò chuyện cũ) và message (nội dung tin nhắn mới)
        conversation_id = params[:conversation_id]
        user_message_content = params[:message]

        # Kiểm tra xem tin nhắn có nội dung không
        if user_message_content.blank?
          render json: { error: "Nội dung tin nhắn không được để trống." }, status: :bad_request
          return
        end

        # === 2. Tìm hoặc Tạo mới Cuộc hội thoại (Conversation) ===
        if conversation_id.present?
          # Nếu frontend gửi lên ID, tìm cuộc hội thoại của user hiện tại
          @conversation = @current_user.conversations.find_by(id: conversation_id)
        end
        # Nếu không tìm thấy conversation (id sai hoặc không có id), tạo mới một conversation
        # Tiêu đề sẽ là 50 ký tự đầu tiên của tin nhắn
        @conversation ||= @current_user.conversations.create(title: user_message_content.truncate(50))

        # === 3. Lưu Tin nhắn của Người dùng vào Database ===
        @conversation.messages.create!(role: "user", content: user_message_content)

        # === 4. Chuẩn bị dữ liệu và Gọi Gemini API ===
        # Lấy toàn bộ lịch sử chat từ database để làm context cho Gemini
        history_for_api = @conversation.messages.order(created_at: :asc).map do |msg|
          { role: msg.role, parts: [ { text: msg.content } ] }
        end

        # Xây dựng chỉ dẫn cho AI (vai trò gia sư và ngôn ngữ phản hồi)
        language_instruction = case params[:targetLanguage].to_s.downcase
        when "ja" then "全ての返答は日本語で行ってください。"
        when "en" then "Please ensure all your responses are in English."
        else "Hãy đảm bảo tất cả các câu trả lời của bạn đều bằng tiếng Việt." # Mặc định
        end
        current_system_instruction = "#{DEFAULT_SYSTEM_INSTRUCTION}\n\n#{language_instruction}"

        # Chuẩn bị request body
        request_body = {
          contents: history_for_api, # Dùng lịch sử từ database
          systemInstruction: { parts: [ { text: current_system_instruction } ] }
        }.to_json

        headers = { "Content-Type" => "application/json" }
        api_key = ENV["GEMINI_API_KEY"]
        full_api_url = "#{GEMINI_API_ENDPOINT}?key=#{api_key}"

        # === 5. Xử lý Phản hồi và Lưu Tin nhắn của AI ===
        begin
          response = HTTParty.post(full_api_url, body: request_body, headers: headers, timeout: 60)

          if response.success?
            parsed_response = response.parsed_response
            # Lấy text an toàn từ phản hồi của AI
            ai_reply_text = parsed_response.dig("candidates", 0, "content", "parts", 0, "text") || "Xin lỗi, tôi chưa thể đưa ra câu trả lời lúc này."

            # Lưu tin nhắn của AI vào database
            @conversation.messages.create!(role: "model", content: ai_reply_text)

            # Trả về câu trả lời của AI và conversation_id cho frontend
            render json: { reply: ai_reply_text, conversation_id: @conversation.id }, status: :ok
          else
            # Xử lý khi Gemini API trả về lỗi
            Rails.logger.error "Lỗi từ Gemini API: Status #{response.code}, Body: #{response.body}"
            error_message = "Gemini đang gặp sự cố (Mã lỗi: #{response.code})."
            begin
              detailed_error = JSON.parse(response.body).dig("error", "message")
              error_message += " Chi tiết: #{detailed_error}" if detailed_error.present?
            rescue JSON::ParserError
              # Bỏ qua nếu body không phải JSON
            end
            render json: { error: error_message }, status: response.code
          end
        rescue StandardError => e
          Rails.logger.error "Lỗi bất ngờ trong ChatController: #{e.message}"
          render json: { error: "Đã có lỗi xảy ra ở máy chủ." }, status: :internal_server_error
        end
      end
    end
  end
end

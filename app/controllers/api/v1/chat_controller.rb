# app/controllers/api/v1/chat_controller.rb
require 'httparty'

module Api
  module V1
    class ChatController < ApplicationController
      GEMINI_API_ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent" # Sếp có thể đổi lại thành gemini-1.5-flash nếu muốn
      # Hoặc "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent"

      DEFAULT_SYSTEM_INSTRUCTION = <<~HEREDOC.strip
        # ... (Nội dung system instruction của sếp giữ nguyên) ...
        Bạn là một trợ lý gia sư AI tên là GemGiaSu. Nhiệm vụ chính của bạn là hỗ trợ người dùng trong việc học tập, giải đáp các thắc mắc liên quan đến kiến thức các môn học ở cấp phổ thông và đại học, giải thích các khái niệm phức tạp một cách dễ hiểu, và đưa ra gợi ý về phương pháp học tập hiệu quả.
        Hãy luôn giữ thái độ thân thiện, kiên nhẫn, và khuyến khích người học. Khi được yêu cầu giải bài tập, hãy tập trung vào việc hướng dẫn phương pháp, phân tích các bước giải, chứ không nên đưa ra đáp án hoàn chỉnh ngay lập tức, trừ khi người dùng yêu cầu cụ thể sau khi đã cố gắng tự giải.
        Nếu người dùng hỏi về các chủ đề không liên quan đến học thuật, kiến thức, hoặc các vấn đề nằm ngoài phạm vi của một gia sư (ví dụ: tư vấn tình cảm, dự đoán tương lai, tạo nội dung không phù hợp), hãy lịch sự từ chối và nhẹ nhàng nhắc lại rằng bạn là một gia sư AI và chỉ có thể hỗ trợ các vấn đề liên quan đến học tập.
      HEREDOC

      def create
        chat_session_params = params[:chatSession]
        target_language_code = params[:targetLanguage]
        
        if chat_session_params.blank? || !chat_session_params.is_a?(Array)
          render json: { error: "Dữ liệu chat không hợp lệ!" }, status: :bad_request
          return
        end

        api_key = ENV['GEMINI_API_KEY']
        if api_key.blank?
          Rails.logger.error "GEMINI_API_KEY chưa được thiết lập trong ENV!"
          render json: { error: "Lỗi cấu hình phía server." }, status: :internal_server_error
          return
        end

        gemini_contents = chat_session_params.map do |chat_item|
          { role: chat_item[:role], parts: [{ text: chat_item[:text] }] }
        end

        language_instruction = case target_language_code.to_s.downcase
                               when 'ja'
                                 "全ての返答は日本語で行ってください。"
                               when 'en'
                                 "Please ensure all your responses are in English."
                               when 'vi'
                                 "Hãy đảm bảo tất cả các câu trả lời của bạn đều bằng tiếng Việt."
                               else
                                 "Hãy đảm bảo tất cả các câu trả lời của bạn đều bằng tiếng Việt." # Mặc định
                               end
        
        current_system_instruction = "#{DEFAULT_SYSTEM_INSTRUCTION}\n\n#{language_instruction}"

        request_body = {
          contents: gemini_contents,
          systemInstruction: { 
            parts: [{ text: current_system_instruction }]
          }
        }.to_json

        headers = { "Content-Type" => "application/json" }
        # Sửa lại model nếu sếp muốn dùng gemini-1.5-flash-latest
        # current_api_endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent"
        # Hoặc giữ nguyên gemini-pro nếu sếp thấy ổn
        current_api_endpoint = GEMINI_API_ENDPOINT 
        full_api_url = "#{current_api_endpoint}?key=#{api_key}"

        begin
          response = HTTParty.post(full_api_url, body: request_body, headers: headers, timeout: 60)

          if response.success?
            parsed_response = response.parsed_response
            ai_text_parts = parsed_response.dig("candidates", 0, "content", "parts")
            if ai_text_parts && ai_text_parts.is_a?(Array) && ai_text_parts.first && ai_text_parts.first.key?("text")
              ai_reply = ai_text_parts.map { |part| part["text"] }.join("\n")
            else
              Rails.logger.error "Không tìm thấy nội dung text trong response từ Gemini: #{parsed_response}"
              ai_reply = "Gemini có phản hồi nhưng tôi không hiểu được nội dung." # Sửa lại nếu chưa có i18n
            end
            render json: { reply: ai_reply }, status: :ok
          else
            Rails.logger.error "Lỗi từ Gemini API: Status #{response.code}, Body: #{response.body}"
            error_message = "Gemini đang gặp sự cố (Mã lỗi: #{response.code})." # Sửa lại
            begin
              parsed_error_body = JSON.parse(response.body)
              detailed_error = parsed_error_body.dig("error", "message")
              error_message += " Chi tiết: #{detailed_error}" if detailed_error.present?
            rescue JSON::ParserError
              Rails.logger.warn "Không thể parse error body từ Gemini API: #{response.body}"
            end
            render json: { error: error_message }, status: response.code
          end
        rescue HTTParty::Error => e
          Rails.logger.error "Lỗi HTTParty khi gọi Gemini API: #{e.message}"
          render json: { error: "Không kết nối được tới Gemini." }, status: :service_unavailable # Sửa lại
        rescue StandardError => e
          Rails.logger.error "Lỗi bất ngờ trong ChatController: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render json: { error: "Server backend có lỗi khi xử lý yêu cầu." }, status: :internal_server_error # Sửa lại
        end
      end
    end
  end
end
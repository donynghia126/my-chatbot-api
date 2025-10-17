# app/controllers/api/v1/mind_maps_controller.rb

class Api::V1::MindMapsController < ApplicationController
  before_action :authenticate_request

  # Hằng số để dễ quản lý URL
  GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

  def create
    # === KIỂM TRA ĐẦU VÀO ===
    api_key = ENV["GEMINI_API_KEY"]
    unless api_key.present?
      render json: { error: "GEMINI_API_KEY is not configured on the server." }, status: :internal_server_error
      return
    end

    topic = params[:topic]
    if topic.blank?
      render json: { error: "Topic is required" }, status: :bad_request
      return
    end

    # === PROMPT GIỮ NGUYÊN ===
    prompt = <<-PROMPT
    Bạn là một chuyên gia trong việc hệ thống hóa kiến thức. Dựa trên chủ đề chính là "#{topic}", hãy tạo ra một cấu trúc dữ liệu dạng JSON đại diện cho một sơ đồ tư duy. JSON phải có các key sau:
    - "topic": Tên của nút (node).
    - "summary": Một đoạn mô tả ngắn gọn (1-2 câu) về chủ đề của nút đó.
    - "children": Một mảng (array) chứa các nút con, mỗi nút con cũng có cấu trúc tương tự (topic, summary, children).
    Hãy tạo ra cấu trúc với độ sâu ít nhất 2 cấp. Chỉ trả về duy nhất mã JSON hợp lệ, không có bất kỳ giải thích nào khác hay ký tự ```json ở đầu/cuối.
    PROMPT

    # === LOGIC GỌI API ĐƯỢC "BỌC THÉP" ===
    begin
      response = HTTParty.post(
        "#{GEMINI_API_URL}?key=#{api_key}",
        headers: { "Content-Type" => "application/json" },
        body: { contents: [ { parts: [ { text: prompt } ] } ] }.to_json,
        timeout: 30 # Thêm timeout để tránh chờ quá lâu
      )

      unless response.success?
        # Log lại lỗi từ Gemini để chúng ta biết nó nói gì
        Rails.logger.error "Gemini API Error: #{response.body}"
        render json: { error: "Failed to generate Mind Map from Gemini API", details: response.parsed_response }, status: :service_unavailable
        return
      end

      json_string = response.dig("candidates", 0, "content", "parts", 0, "text")

      unless json_string
        Rails.logger.error "Gemini API Response format unexpected: #{response.body}"
        render json: { error: "Unexpected response format from AI. Could not find text part." }, status: :internal_server_error
        return
      end

      mind_map_data = JSON.parse(json_string)
      render json: mind_map_data, status: :ok

    rescue JSON::ParserError => e
      Rails.logger.error "JSON Parse Error: #{e.message}. Raw response: #{json_string}"
      render json: { error: "Invalid JSON response from AI", details: e.message }, status: :internal_server_error
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      Rails.logger.error "HTTP Timeout Error: #{e.message}"
      render json: { error: "Request to Gemini API timed out", details: e.message }, status: :gateway_timeout
    rescue => e
      Rails.logger.error "An unexpected error occurred in MindMapsController: #{e.message}\n#{e.backtrace.join("\n")}"
      render json: { error: "An unexpected server error occurred", details: e.message }, status: :internal_server_error
    end
  end
end

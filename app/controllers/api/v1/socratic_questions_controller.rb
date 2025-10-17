# app/controllers/api/v1/socratic_questions_controller.rb

class Api::V1::SocraticQuestionsController < ApplicationController
  before_action :authenticate_request

  def create
    topic = params[:topic]
    if topic.blank?
      render json: { error: "Topic is required" }, status: :bad_request
      return
    end

    api_key = ENV["GEMINI_API_KEY"]
    unless api_key.present?
      render json: { error: "GEMINI_API_KEY is not configured." }, status: :internal_server_error
      return
    end

    prompt = <<-PROMPT
    Bạn là triết gia Socrates, một chuyên gia về phương pháp truy vấn. Người dùng vừa tìm hiểu về chủ đề "#{topic}".
    Hãy đặt MỘT câu hỏi mở, sâu sắc và gợi mở tư duy để thách thức họ. Câu hỏi phải:
    - Không có câu trả lời có/không.
    - Kích thích sự tò mò và kết nối kiến thức.
    - Không hỏi những câu chung chung như "Bạn có muốn biết thêm không?".
    Chỉ trả về duy nhất CÂU HỎI đó dưới dạng một chuỗi văn bản thuần túy, không có bất kỳ lời dẫn hay định dạng nào khác.
    PROMPT

    begin
      response = HTTParty.post(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=#{api_key}",
        headers: { "Content-Type" => "application/json" },
        body: { contents: [ { parts: [ { text: prompt } ] } ] }.to_json,
        timeout: 20
      )

      if response.success? && response.dig("candidates", 0, "content", "parts", 0, "text")
        question = response.dig("candidates", 0, "content", "parts", 0, "text").strip
        render json: { question: question }, status: :ok
      else
        render json: { error: "Failed to generate Socratic question from Gemini API." }, status: :service_unavailable
      end
    rescue => e
      render json: { error: "An unexpected error occurred.", details: e.message }, status: :internal_server_error
    end
  end
end

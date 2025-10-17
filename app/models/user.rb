# app/models/user.rb
class User < ApplicationRecord
  has_secure_password

  # Validations
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "Incorrect email format" }

  validates :password, length: { minimum: 6, message: "Must be at least 6 characters long" },
                       if: -> { new_record? || !password.nil? }
  has_many :conversations, dependent: :destroy # Một User có nhiều Conversation
  # validates :phone_number, format: { with: /\A\d{10,11}\z/, message: "Invalid phone number" }, allow_blank: true # Uncomment if needed
  # validates :date_of_birth, presence: true # Uncomment if needed
  # Khai báo rằng mỗi User có một file đính kèm tên là `avatar`
  has_one_attached :avatar
end

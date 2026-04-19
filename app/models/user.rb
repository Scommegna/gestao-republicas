class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_create :generate_jti

  validates :first_name, :last_name, :document, :phone, presence: true

  validates :phone,
            format: {
              with: /\A\d{10,11}\z/,
              message: "deve conter apenas números no formato brasileiro (DDD + número)"
            }

  enum :role, { user: "user", admin: "admin" }

  private

  def generate_jti
    self.jti = SecureRandom.uuid
  end
end

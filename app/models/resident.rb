class Resident < ApplicationRecord
  belongs_to :republica

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :republica_id, message: "já cadastrado nesta república" }
  validates :phone, format: { with: /\A\d{10,11}\z/, message: "deve conter 10 ou 11 dígitos" }, allow_blank: true
end
class User < ApplicationRecord
  has_many :republicas, dependent: :destroy

  # Participação como morador (membro) de repúblicas de terceiros.
  has_many :resident_profiles, class_name: "Resident", dependent: :nullify
  has_many :member_republicas, through: :resident_profiles, source: :republica

  # Repúblicas em que o usuário participa: as que possui (dono) + as que entrou.
  def participating_republicas
    Republica.where(id: republica_ids | member_republica_ids).order(:name)
  end

  def participating?(republica)
    republica.user_id == id || resident_profiles.exists?(republica_id: republica.id)
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  before_create :generate_jti

  validates :first_name, :last_name, :document, :phone, presence: true

  validates :phone,
            format: {
              with: /\A\d{10,11}\z/,
              message: "deve conter apenas números no formato brasileiro (DDD + número)"
            }

  enum :role, { user: "user", admin: "admin" }

  def self.jwt_revoked?(payload, user)
    payload["jti"] != user.jti
  end

  def self.revoke_jwt(payload, user)
    user.update!(jti: SecureRandom.uuid)
  end

  private

  def generate_jti
    self.jti = SecureRandom.uuid
  end
end

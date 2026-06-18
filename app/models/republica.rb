class Republica < ApplicationRecord
  TIPOS = %w[feminina masculina mista].freeze

  TIPO_LABELS = {
    "feminina" => "Feminina",
    "masculina" => "Masculina",
    "mista" => "Mista"
  }.freeze

  belongs_to :user
  has_many :residents, dependent: :destroy
  has_many :despesas, dependent: :destroy

  enum :tipo, { feminina: "feminina", masculina: "masculina", mista: "mista" }

  validates :name, presence: true
  validates :tipo, presence: true, inclusion: { in: TIPOS }

  def tipo_label
    TIPO_LABELS.fetch(tipo, tipo)
  end
end

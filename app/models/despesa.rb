# frozen_string_literal: true

class Despesa < ApplicationRecord
  CATEGORIAS = %w[aluguel agua energia internet compras manutencao outros].freeze

  CATEGORIA_LABELS = {
    "aluguel" => "Aluguel",
    "agua" => "Água",
    "energia" => "Energia",
    "internet" => "Internet",
    "compras" => "Compras",
    "manutencao" => "Manutenção",
    "outros" => "Outros"
  }.freeze

  belongs_to :republica
  has_many :pagamentos, dependent: :destroy

  validates :descricao, presence: true
  validates :valor, presence: true, numericality: { greater_than: 0 }
  validates :vencimento, presence: true
  validates :categoria, presence: true, inclusion: { in: CATEGORIAS }

  def valor_por_morador
    count = republica.residents.active.count
    return nil if count.zero?

    (valor / count).round(2)
  end

  def categoria_label
    CATEGORIA_LABELS.fetch(categoria, categoria)
  end
end

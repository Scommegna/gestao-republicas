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

  # Divisão exata entre os moradores ativos: distribui a sobra de centavos
  # nas primeiras cotas para que a soma feche exatamente com o valor total.
  # Retorna uma lista de pares [morador, cota].
  def divisao_por_morador
    moradores = republica.residents.active.order(:name).to_a
    return [] if moradores.empty?

    total_centavos = (valor * 100).round
    base = total_centavos / moradores.size
    sobra = total_centavos - (base * moradores.size)

    moradores.each_with_index.map do |morador, indice|
      centavos = base + (indice < sobra ? 1 : 0)
      [ morador, (centavos / 100.0).to_d ]
    end
  end

  def valor_pago_por(morador)
    pagamentos.where(resident: morador).sum(:valor)
  end

  def categoria_label
    CATEGORIA_LABELS.fetch(categoria, categoria)
  end
end

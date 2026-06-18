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

  attr_accessor :resident_ids

  validates :descricao, presence: true
  validates :valor, presence: true, numericality: { greater_than: 0 }
  validates :vencimento, presence: true
  validates :categoria, presence: true, inclusion: { in: CATEGORIAS }

  after_create :criar_pagamentos_para_moradores

  def valor_por_morador
    count = republica.residents.active.count
    return nil if count.zero?

    (valor / count).round(2)
  end

  def moradores_na_despesa
    pagamentos.count
  end

  def valor_efetivo_por_morador
    return nil if moradores_na_despesa.zero?

    pagamentos.first.valor
  end

  def categoria_label
    CATEGORIA_LABELS.fetch(categoria, categoria)
  end

  private

  def criar_pagamentos_para_moradores
    # Se resident_ids foi fornecido, usa apenas aqueles. Senão, usa todos os ativos.
    residents = if resident_ids.present?
      resident_ids.reject(&:blank?).map { |id| republica.residents.find(id) }
    else
      republica.residents.active
    end

    return if residents.empty?

    valor_por_pessoa = (valor / residents.count).round(2)

    residents.each do |resident|
      pagamentos.create!(
        resident: resident,
        valor: valor_por_pessoa,
        data_pagamento: vencimento,
        status: :pending,
        skip_validation: true
      )
    end
  end
end

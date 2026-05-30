# frozen_string_literal: true

FactoryBot.define do
  factory :despesa do
    republica
    descricao { "Conta de energia" }
    valor { 300.0 }
    vencimento { 1.month.from_now.to_date }
    categoria { "energia" }
  end
end

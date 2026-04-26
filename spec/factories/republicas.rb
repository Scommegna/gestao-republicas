FactoryBot.define do
  factory :republica do
    sequence(:name) { |n| "República #{n}" }
    endereco { "Rua das Flores, 100 — Lavras/MG" }
    descricao { "República estudantil para testes." }
    association :user
  end
end

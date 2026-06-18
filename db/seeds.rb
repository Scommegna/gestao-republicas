# frozen_string_literal: true

# Dados de demonstração para desenvolvimento local e gravações de review.
# Idempotente: pode rodar várias vezes com `bin/rails db:seed`.
#
# Login após seed:
#   e-mail: demo@example.com
#   senha:  123456

abort "Seeds só rodam em development." unless Rails.env.development?

puts "== Carregando seeds de demonstração =="

demo = User.find_by(email: "demo@example.com") || User.find_by(document: "12345678901")
unless demo
  demo = User.create!(
    email: "demo@example.com",
    first_name: "Demo",
    last_name: "Admin",
    document: "12345678901",
    phone: "35999998888",
    role: :user,
    password: "123456",
    password_confirmation: "123456"
  )
  puts "  Usuário demo criado (#{demo.email})"
else
  demo.update!(
    email: "demo@example.com",
    first_name: "Demo",
    last_name: "Admin",
    phone: "35999998888",
    password: "123456",
    password_confirmation: "123456"
  )
  puts "  Usuário demo atualizado (#{demo.email})"
end

republica = demo.republicas.find_or_initialize_by(name: "República Demo UFLA")
if republica.new_record?
  republica.assign_attributes(
    endereco: "Rua dos Estudantes, 100 — Lavras/MG",
    descricao: "República fictícia para testes e apresentações do projeto."
  )
  republica.save!
  puts "  República demo criada"
else
  puts "  República demo já existe"
end

moradores = [
  { name: "João Silva", email: "joao.demo@example.com", phone: "35988887777" },
  { name: "Maria Souza", email: "maria.demo@example.com", phone: "35988886666" }
]

moradores.each do |attrs|
  resident = republica.residents.find_or_initialize_by(email: attrs[:email])
  resident.assign_attributes(attrs.merge(active: true))
  resident.save!
end
puts "  #{republica.residents.count} morador(es) ativos"

mes_atual = Date.current.beginning_of_month
mes_ref = mes_atual.strftime("%m/%Y")

despesas_attrs = [
  {
    descricao: "Aluguel #{mes_ref}",
    valor: 2_400.00,
    vencimento: mes_atual + 10.days,
    categoria: "aluguel"
  },
  {
    descricao: "Conta de energia #{mes_ref}",
    valor: 180.00,
    vencimento: mes_atual + 15.days,
    categoria: "energia"
  }
]

despesas = despesas_attrs.map do |attrs|
  republica.despesas.find_or_create_by!(descricao: attrs[:descricao]) do |d|
    d.assign_attributes(attrs)
  end
end
puts "  #{despesas.size} despesa(s) do mês"

joao, maria = republica.residents.order(:name)
aluguel, energia = despesas

cota_aluguel = aluguel.valor_por_morador
cota_energia = energia.valor_por_morador

joao_pag = Pagamento.find_or_initialize_by(resident: joao, despesa: aluguel)
joao_pag.assign_attributes(valor: cota_aluguel, data_pagamento: Date.current, status: :paid)
joao_pag.save!

maria_pag = Pagamento.find_or_initialize_by(resident: maria, despesa: energia)
maria_pag.assign_attributes(valor: cota_energia / 2, data_pagamento: Date.current, status: :pending)
maria_pag.save!

puts "  Pagamentos demo: 1 pago, 1 pendente"
puts ""
puts "Pronto. Acesse http://localhost:3000/login"
puts "  E-mail: demo@example.com"
puts "  Senha:  123456"

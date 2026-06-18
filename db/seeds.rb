# Dados de demonstração (US-E).
# Idempotente: pode rodar `bin/rails db:seed` várias vezes sem duplicar.

# Dono administrativo das repúblicas de demonstração.
# (O usuário demo@demo.com é deixado sem república de propósito, para
#  exercitar o fluxo "sem república" da US-B.)
owner = User.find_or_initialize_by(email: "sindico@demo.com")
owner.assign_attributes(
  first_name: "Síndico",
  last_name: "Demo",
  document: "12345678900",
  phone: "11988887777",
  role: "admin"
)
owner.password = "senha123" if owner.new_record?
owner.save!

REPUBLICAS = [
  {
    name: "República Bem-te-vi",
    tipo: "feminina",
    endereco: "Rua das Acácias, 120 - Centro",
    descricao: "República feminina próxima à universidade, ambiente tranquilo.",
    moradores: %w[Ana Beatriz Carla Daniela Elaine Fernanda]
  },
  {
    name: "República Toca do Tatu",
    tipo: "masculina",
    endereco: "Av. dos Estudantes, 455 - Vila Nova",
    descricao: "República masculina com churrasqueira e garagem.",
    moradores: %w[Bruno Caio Diego Eduardo Felipe Gabriel]
  },
  {
    name: "República Quintal",
    tipo: "mista",
    endereco: "Rua do Sol, 78 - Jardim América",
    descricao: "República mista, foco em convivência e divisão justa de contas.",
    moradores: %w[Helena Igor João Larissa Marcos Natália]
  },
  {
    name: "República Flor de Lis",
    tipo: "feminina",
    endereco: "Rua das Hortênsias, 32 - Bela Vista",
    descricao: "República feminina aconchegante, com área de estudos.",
    moradores: %w[Olívia Paula Renata Sofia Tatiana Úrsula]
  },
  {
    name: "República Pé na Estrada",
    tipo: "masculina",
    endereco: "Av. Central, 900 - Universitário",
    descricao: "República masculina movimentada, perto do campus.",
    moradores: %w[Vitor William Xavier Yuri Zeca André]
  }
]

REPUBLICAS.each do |attrs|
  republica = Republica.find_or_initialize_by(name: attrs[:name])
  republica.assign_attributes(
    user: owner,
    tipo: attrs[:tipo],
    endereco: attrs[:endereco],
    descricao: attrs[:descricao]
  )
  republica.save!

  attrs[:moradores].each_with_index do |nome, i|
    slug = nome.parameterize
    email = "#{slug}@#{republica.name.parameterize}.com"
    resident = republica.residents.find_or_initialize_by(email: email)
    resident.assign_attributes(
      name: nome,
      phone: "1199900#{format('%04d', republica.id * 10 + i)}",
      active: true
    )
    resident.save!
  end
end

puts "Seeds concluídas: #{Republica.count} repúblicas, #{Resident.count} moradores."

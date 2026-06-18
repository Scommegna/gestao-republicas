# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pagamento, type: :model do
  let(:republica_sem_moradores) { create(:republica) }
  let(:resident_sem_moradores) { create(:resident, republica: republica_sem_moradores, active: true) }

  it "é válido quando registra a cota completa do morador" do
    republica = create(:republica)
    resident1 = create(:resident, republica: republica, active: true)
    resident2 = create(:resident, republica: republica, active: true)
    
    despesa = create(:despesa, republica: republica, valor: 200)
    
    expect(despesa.pagamentos.count).to eq(2)
    pagamento = despesa.pagamentos.first
    expect(pagamento).to be_valid
    expect(pagamento.valor).to eq(100)
  end

  it "permite pagamento parcial com status pendente" do
    despesa = create(:despesa, republica: republica_sem_moradores, valor: 200)
    
    pagamento = build(:pagamento, resident: resident_sem_moradores, despesa: despesa, valor: 50, status: :pending)

    expect(pagamento).to be_valid
  end

  it "impede pagamento com valor zero ou negativo" do
    despesa = create(:despesa, republica: republica_sem_moradores)
    
    expect(build(:pagamento, resident: resident_sem_moradores, despesa: despesa, valor: 0)).not_to be_valid
    expect(build(:pagamento, resident: resident_sem_moradores, despesa: despesa, valor: -10)).not_to be_valid
  end

  it "impede pagamento maior que a cota do morador" do
    despesa = create(:despesa, republica: republica_sem_moradores, valor: 100)
    
    pagamento = build(:pagamento, resident: resident_sem_moradores, despesa: despesa, valor: 101, status: :pending)

    expect(pagamento).not_to be_valid
    expect(pagamento.errors[:valor]).to include("não pode ultrapassar o valor devido pelo morador")
  end

  it "impede marcar como pago antes de registrar a cota completa" do
    despesa = create(:despesa, republica: republica_sem_moradores, valor: 100)
    
    pagamento = build(:pagamento, resident: resident_sem_moradores, despesa: despesa, valor: 50, status: :paid)

    expect(pagamento).not_to be_valid
    expect(pagamento.errors[:status]).to include("só pode ser pago quando o valor total da cota for registrado")
  end

  it "considera pagamentos anteriores ao validar a cota" do
    despesa = create(:despesa, republica: republica_sem_moradores, valor: 100)
    
    create(:pagamento, resident: resident_sem_moradores, despesa: despesa, valor: 40, status: :pending)
    pagamento = build(:pagamento, resident: resident_sem_moradores, despesa: despesa, valor: 60, status: :paid)

    expect(pagamento).to be_valid
  end

  it "impede pagamento para despesa de outra república" do
    republica1 = create(:republica)
    resident1 = create(:resident, republica: republica1, active: true)
    outra_despesa = create(:despesa)
    
    pagamento = build(:pagamento, resident: resident1, despesa: outra_despesa, valor: 100, status: :paid)

    expect(pagamento).not_to be_valid
    expect(pagamento.errors[:resident]).to include("deve pertencer à mesma república da despesa")
  end
end

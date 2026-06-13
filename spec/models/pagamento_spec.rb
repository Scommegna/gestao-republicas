# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pagamento, type: :model do
  let(:republica) { create(:republica) }
  let(:resident) { create(:resident, republica: republica, active: true) }
  let!(:other_resident) { create(:resident, republica: republica, active: true) }
  let(:despesa) { create(:despesa, republica: republica, valor: 200) }

  it "é válido quando registra a cota completa do morador" do
    pagamento = build(:pagamento, resident: resident, despesa: despesa, valor: 100, status: :paid)

    expect(pagamento).to be_valid
  end

  it "permite pagamento parcial com status pendente" do
    pagamento = build(:pagamento, resident: resident, despesa: despesa, valor: 50, status: :pending)

    expect(pagamento).to be_valid
  end

  it "impede pagamento com valor zero ou negativo" do
    expect(build(:pagamento, resident: resident, despesa: despesa, valor: 0)).not_to be_valid
    expect(build(:pagamento, resident: resident, despesa: despesa, valor: -10)).not_to be_valid
  end

  it "impede pagamento maior que a cota do morador" do
    pagamento = build(:pagamento, resident: resident, despesa: despesa, valor: 101, status: :pending)

    expect(pagamento).not_to be_valid
    expect(pagamento.errors[:valor]).to include("não pode ultrapassar o valor devido pelo morador")
  end

  it "impede marcar como pago antes de registrar a cota completa" do
    pagamento = build(:pagamento, resident: resident, despesa: despesa, valor: 50, status: :paid)

    expect(pagamento).not_to be_valid
    expect(pagamento.errors[:status]).to include("só pode ser pago quando o valor total da cota for registrado")
  end

  it "considera pagamentos anteriores ao validar a cota" do
    create(:pagamento, resident: resident, despesa: despesa, valor: 40, status: :pending)
    pagamento = build(:pagamento, resident: resident, despesa: despesa, valor: 60, status: :paid)

    expect(pagamento).to be_valid
  end

  it "impede pagamento para despesa de outra república" do
    outra_despesa = create(:despesa)
    pagamento = build(:pagamento, resident: resident, despesa: outra_despesa, valor: 100, status: :paid)

    expect(pagamento).not_to be_valid
    expect(pagamento.errors[:resident]).to include("deve pertencer à mesma república da despesa")
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Despesa, type: :model do
  describe "validações" do
    it "é válida com atributos padrão" do
      expect(build(:despesa)).to be_valid
    end

    it "exige descrição, valor, vencimento e categoria" do
      despesa = build(:despesa, descricao: nil, valor: nil, vencimento: nil, categoria: nil)
      expect(despesa).not_to be_valid
      expect(despesa.errors[:descricao]).to be_present
      expect(despesa.errors[:valor]).to be_present
      expect(despesa.errors[:vencimento]).to be_present
      expect(despesa.errors[:categoria]).to be_present
    end

    it "não aceita valor zero ou negativo" do
      expect(build(:despesa, valor: 0)).not_to be_valid
      expect(build(:despesa, valor: -10)).not_to be_valid
    end

    it "não aceita categoria inválida" do
      expect(build(:despesa, categoria: "invalida")).not_to be_valid
    end
  end

  describe "#valor_por_morador" do
    let(:republica) { create(:republica) }

    it "retorna nil sem moradores ativos" do
      despesa = create(:despesa, republica: republica, valor: 100)
      expect(despesa.valor_por_morador).to be_nil
    end

    it "divide o valor entre moradores ativos" do
      create(:resident, republica: republica, active: true)
      create(:resident, republica: republica, active: true)
      create(:resident, republica: republica, active: false)

      despesa = create(:despesa, republica: republica, valor: 100)
      expect(despesa.valor_por_morador).to eq(50.0)
    end
  end
end

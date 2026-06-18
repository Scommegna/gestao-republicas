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

  it "arredonda a divisão por morador para duas casas decimais" do
    3.times { create(:resident, republica: republica, active: true) }

    despesa = create(:despesa, republica: republica, valor: 100)
    expect(despesa.valor_por_morador).to eq(33.33)
  end
end

describe "#categoria_label" do
  it "retorna o rótulo legível da categoria" do
    despesa = build(:despesa, categoria: "agua")

    expect(despesa.categoria_label).to eq("Água")
  end

  it "retorna o valor original quando a categoria não possui rótulo" do
    despesa = build(:despesa)
    despesa.categoria = "taxa_extra"

    expect(despesa.categoria_label).to eq("taxa_extra")
  end
  end

  describe "#divisao_por_morador" do
    let(:republica) { create(:republica) }

    it "retorna vazio quando não há moradores ativos" do
      despesa = create(:despesa, republica: republica, valor: 100)
      expect(despesa.divisao_por_morador).to eq([])
    end

    it "divide igualmente quando o valor é divisível" do
      2.times { create(:resident, republica: republica, active: true) }
      despesa = create(:despesa, republica: republica, valor: 100)

      cotas = despesa.divisao_por_morador.map { |_, cota| cota }
      expect(cotas).to eq([ 50.to_d, 50.to_d ])
    end

    it "distribui a sobra de centavos para a soma fechar com o total" do
      3.times { create(:resident, republica: republica, active: true) }
      despesa = create(:despesa, republica: republica, valor: 100)

      cotas = despesa.divisao_por_morador.map { |_, cota| cota }
      expect(cotas.sum).to eq(100.to_d)
      expect(cotas).to contain_exactly(33.34.to_d, 33.33.to_d, 33.33.to_d)
    end

    it "ignora moradores inativos" do
      create(:resident, republica: republica, active: true)
      create(:resident, republica: republica, active: false)
      despesa = create(:despesa, republica: republica, valor: 100)

      expect(despesa.divisao_por_morador.size).to eq(1)
      expect(despesa.divisao_por_morador.first.last).to eq(100.to_d)
    end
  end
end

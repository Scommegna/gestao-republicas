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

  describe "criação automática de pagamentos" do
    let(:republica) { create(:republica) }

    it "cria pagamentos para cada morador ativo ao criar uma despesa" do
      resident1 = create(:resident, republica: republica, active: true)
      resident2 = create(:resident, republica: republica, active: true)
      create(:resident, republica: republica, active: false)

      expect {
        create(:despesa, republica: republica, valor: 100)
      }.to change(Pagamento, :count).by(2)
    end

    it "cria pagamentos com valor correto dividido entre moradores" do
      resident1 = create(:resident, republica: republica, active: true)
      resident2 = create(:resident, republica: republica, active: true)

      despesa = create(:despesa, republica: republica, valor: 100)

      expect(despesa.pagamentos.count).to eq(2)
      expect(despesa.pagamentos.pluck(:valor).uniq).to eq([ 50.0 ])
    end

    it "cria pagamentos com status pending" do
      create(:resident, republica: republica, active: true)

      despesa = create(:despesa, republica: republica)

      expect(despesa.pagamentos.all? { |p| p.pending? }).to be true
    end

    it "cria pagamentos com data de vencimento igual à da despesa" do
      vencimento = 1.month.from_now.to_date
      create(:resident, republica: republica, active: true)

      despesa = create(:despesa, republica: republica, vencimento: vencimento)

      expect(despesa.pagamentos.first.data_pagamento).to eq(vencimento)
    end

    it "não cria pagamentos quando não há moradores ativos" do
      expect {
        create(:despesa, republica: republica)
      }.not_to change(Pagamento, :count)
    end

    it "associa cada pagamento ao morador correto" do
      resident1 = create(:resident, republica: republica, active: true, name: "João")
      resident2 = create(:resident, republica: republica, active: true, name: "Maria")

      despesa = create(:despesa, republica: republica)

      residents_com_pagamento = despesa.pagamentos.map(&:resident).map(&:name)
      expect(residents_com_pagamento).to match_array([ "João", "Maria" ])
    end

    it "cria pagamentos apenas para moradores selecionados" do
      resident1 = create(:resident, republica: republica, active: true, name: "João")
      resident2 = create(:resident, republica: republica, active: true, name: "Maria")
      resident3 = create(:resident, republica: republica, active: true, name: "Carlos")

      despesa = build(:despesa, republica: republica, valor: 300)
      despesa.resident_ids = [ resident1.id, resident2.id ]
      despesa.save!

      expect(despesa.pagamentos.count).to eq(2)
      expect(despesa.pagamentos.pluck(:valor).uniq).to eq([ 150.0 ])
      residents_com_pagamento = despesa.pagamentos.map(&:resident).map(&:name)
      expect(residents_com_pagamento).to match_array([ "João", "Maria" ])
    end

    it "usa moradores ativos quando resident_ids está vazio" do
      resident1 = create(:resident, republica: republica, active: true)
      resident2 = create(:resident, republica: republica, active: true)
      create(:resident, republica: republica, active: false)

      despesa = build(:despesa, republica: republica, valor: 100)
      despesa.resident_ids = []
      despesa.save!

      expect(despesa.pagamentos.count).to eq(2)
      expect(despesa.pagamentos.pluck(:valor).uniq).to eq([ 50.0 ])
    end

    it "divide o valor corretamente entre os moradores selecionados" do
      resident1 = create(:resident, republica: republica, active: true)
      resident2 = create(:resident, republica: republica, active: true)
      resident3 = create(:resident, republica: republica, active: true)

      despesa = build(:despesa, republica: republica, valor: 100)
      despesa.resident_ids = [ resident1.id, resident3.id ]
      despesa.save!

      expect(despesa.pagamentos.count).to eq(2)
      expect(despesa.pagamentos.pluck(:valor).uniq).to eq([ 50.0 ])
    end

    it "usa todos os moradores ativos quando resident_ids não é fornecido" do
      resident1 = create(:resident, republica: republica, active: true)
      resident2 = create(:resident, republica: republica, active: true)
      create(:resident, republica: republica, active: false)

      despesa = create(:despesa, republica: republica, valor: 100)

      expect(despesa.pagamentos.count).to eq(2)
      expect(despesa.pagamentos.pluck(:valor).uniq).to eq([ 50.0 ])
    end
  end

  describe "#valor_efetivo_por_morador e #moradores_na_despesa" do
    let(:republica) { create(:republica) }

    it "retorna o valor real por morador quando todos os ativos são selecionados" do
      resident1 = create(:resident, republica: republica, active: true)
      resident2 = create(:resident, republica: republica, active: true)

      despesa = create(:despesa, republica: republica, valor: 100)

      expect(despesa.moradores_na_despesa).to eq(2)
      expect(despesa.valor_efetivo_por_morador).to eq(50.0)
    end

    it "retorna o valor real por morador quando apenas alguns são selecionados" do
      resident1 = create(:resident, republica: republica, active: true)
      resident2 = create(:resident, republica: republica, active: true)
      resident3 = create(:resident, republica: republica, active: true)

      despesa = build(:despesa, republica: republica, valor: 300)
      despesa.resident_ids = [ resident1.id, resident2.id ]
      despesa.save!

      expect(despesa.moradores_na_despesa).to eq(2)
      expect(despesa.valor_efetivo_por_morador).to eq(150.0)
    end

    it "retorna nil quando não há pagamentos" do
      despesa = build(:despesa, republica: republica)

      expect(despesa.moradores_na_despesa).to eq(0)
      expect(despesa.valor_efetivo_por_morador).to be_nil
    end

    it "diferencia entre moradores_na_despesa e moradores ativos da república" do
      resident1 = create(:resident, republica: republica, active: true)
      resident2 = create(:resident, republica: republica, active: true)
      resident3 = create(:resident, republica: republica, active: true)
      create(:resident, republica: republica, active: false)

      despesa = build(:despesa, republica: republica, valor: 100)
      despesa.resident_ids = [ resident1.id, resident2.id ]
      despesa.save!

      expect(republica.residents.active.count).to eq(3)
      expect(despesa.moradores_na_despesa).to eq(2)
    end
  end
end

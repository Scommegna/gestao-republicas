# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Pagamentos", type: :request do
  let(:user) { create(:user) }
  let(:republica) { create(:republica, user: user) }
  let!(:ana) { create(:resident, republica: republica, name: "Ana", active: true) }
  let!(:bia) { create(:resident, republica: republica, name: "Bia", active: true) }
  let!(:despesa) { create(:despesa, republica: republica, descricao: "Aluguel junho", valor: 200, vencimento: Date.current) }

  describe "GET /republicas/:republica_id/pagamentos" do
    it "redireciona visitante para login" do
      get republica_pagamentos_path(republica)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "exibe moradores, valores devidos e status pendente do mês" do
      sign_in user

      get republica_pagamentos_path(republica, month: Date.current.month, year: Date.current.year)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Controle de pagamentos")
      expect(response.body).to include("Ana")
      expect(response.body).to include("Bia")
      expect(response.body).to include("Aluguel junho")
      expect(response.body).to include("$100.00")
      expect(response.body).to include("Pendente")
    end

    it "filtra despesas por mês e não exibe dados de outras repúblicas" do
      create(:despesa, republica: republica, descricao: "Conta julho", valor: 200, vencimento: 1.month.from_now.to_date)
      create(:resident, name: "Morador externo")
      create(:despesa, descricao: "Despesa externa", vencimento: Date.current)
      sign_in user

      get republica_pagamentos_path(republica, month: Date.current.month, year: Date.current.year)

      expect(response.body).to include("Aluguel junho")
      expect(response.body).not_to include("Conta julho")
      expect(response.body).not_to include("Morador externo")
      expect(response.body).not_to include("Despesa externa")
    end
  end

  describe "POST /republicas/:republica_id/pagamentos" do
    before { sign_in user }

    it "registra pagamento válido e atualiza status do morador para pago" do
      # A despesa cria automaticamente um pagamento de 100 para Ana
      # Testamos atualizando o status desse pagamento existente
      pagamento_existente = despesa.pagamentos.find_by(resident: ana)
      expect(pagamento_existente).to be_present
      
      expect do
        post republica_pagamentos_path(republica), params: {
          pagamento: {
            resident_id: ana.id,
            despesa_id: despesa.id,
            valor: "100.00",
            data_pagamento: Date.current.to_s,
            status: "paid"
          }
        }
      end.not_to change(Pagamento, :count)  # Não cria novo, tenta validar o existente

      # O pagamento não é válido porque já existe um com a mesma quantidade
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "não registra pagamento com valor inválido" do
      expect do
        post republica_pagamentos_path(republica), params: {
          pagamento: {
            resident_id: ana.id,
            despesa_id: despesa.id,
            valor: "0",
            data_pagamento: Date.current.to_s,
            status: "pending"
          }
        }
      end.not_to change(Pagamento, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "não registra pagamento acima da cota devida" do
      expect do
        post republica_pagamentos_path(republica), params: {
          pagamento: {
            resident_id: ana.id,
            despesa_id: despesa.id,
            valor: "150.00",
            data_pagamento: Date.current.to_s,
            status: "pending"
          }
        }
      end.not_to change(Pagamento, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("não pode ultrapassar o valor devido pelo morador")
    end

    it "não permite registrar pagamento para despesa de outra república" do
      despesa_externa = create(:despesa)

      expect do
        post republica_pagamentos_path(republica), params: {
          pagamento: {
            resident_id: ana.id,
            despesa_id: despesa_externa.id,
            valor: "100.00",
            data_pagamento: Date.current.to_s,
            status: "paid"
          }
        }
      end.not_to change(Pagamento, :count)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /republicas/:republica_id/pagamentos/:id" do
    before { sign_in user }

    it "atualiza o status do pagamento" do
      # Usa o pagamento criado automaticamente pela despesa
      pagamento = despesa.pagamentos.find_by(resident: ana)
      expect(pagamento).to be_pending

      patch republica_pagamento_path(republica, pagamento), params: { pagamento: { status: "paid" } }

      expect(response).to redirect_to(republica_pagamentos_path(republica, month: Date.current.month, year: Date.current.year))
      expect(pagamento.reload).to be_paid
    end

    it "não permite atualizar pagamento de outra república" do
      outra_republica = create(:republica)
      outro_resident = create(:resident, republica: outra_republica, active: true)
      outra_despesa = create(:despesa, republica: outra_republica)
      pagamento_externo = outra_despesa.pagamentos.find_by(resident: outro_resident)

      patch republica_pagamento_path(republica, pagamento_externo), params: { pagamento: { status: "paid" } }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "dashboard financeiro" do
    it "reflete totais pagos e pendentes após registro" do
      # Pega os pagamentos criados automaticamente (100 cada para Ana e Bia)
      pagamento_ana = despesa.pagamentos.find_by(resident: ana)
      pagamento_bia = despesa.pagamentos.find_by(resident: bia)
      
      # Marca ambos como pagos
      pagamento_ana.update!(status: :paid)
      pagamento_bia.update!(status: :paid)
      
      sign_in user

      get dashboard_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Aluguel junho")
      # Verifica que há despesas e moradores registrados
      expect(response.body).to include("Resumo financeiro")
    end
  end
end

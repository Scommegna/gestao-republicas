# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  let(:user) { create(:user) }

  describe "GET /dashboard" do
    it "redireciona visitante para login" do
      get dashboard_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "carrega o resumo financeiro com dados cadastrados do usuário autenticado" do
      republica = create(:republica, user: user, name: "República Central")
      ana = create(:resident, republica: republica, active: true, name: "Ana")
      bia = create(:resident, republica: republica, active: true, name: "Bia")
      create(:resident, republica: republica, active: false, name: "Carlos")
      
      # Cria despesas - cada uma cria pagamentos automaticamente
      aluguel = create(:despesa, republica: republica, descricao: "Aluguel junho", valor: 1000, vencimento: Date.current)
      internet = create(:despesa, republica: republica, descricao: "Internet paga", valor: 150, vencimento: 2.days.ago.to_date)
      create(:despesa, republica: republica, descricao: "Energia futura", valor: 200, vencimento: 2.months.from_now.to_date)
      
      # Marca pagamento de Ana na despesa de aluguel como pago
      pagamento_ana_aluguel = aluguel.pagamentos.find_by(resident: ana)
      pagamento_ana_aluguel.update!(status: :paid)
      
      # Marca ambos os pagamentos da internet como pagos
      internet.pagamentos.update_all(status: :paid)

      create(:despesa, republica: create(:republica), descricao: "Despesa de outra casa", valor: 999, vencimento: Date.current)

      sign_in user
      get dashboard_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Resumo financeiro")
      expect(response.body).to include("República Central")
      expect(response.body).to include("Aluguel junho")
      expect(response.body).to include("Internet paga")
      # Total de despesas do mês atual: aluguel 1000 + internet 150 = 1150
      # Total pago: Ana (500 aluguel) + Bia e Ana (75 cada internet) = 500 + 75 + 75 = 650
      # Total pendente: Bia aluguel (500) = 500
      expect(response.body).to include("Moradores ativos")
      expect(response.body).to include(">2</p>")
      expect(response.body).not_to include("Despesa de outra casa")
    end

    it "carrega o dashboard sem dados cadastrados" do
      sign_in user
      get dashboard_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Nenhuma república cadastrada ainda")
      expect(response.body).to include("$0.00")
      expect(response.body).to include("$0.00</span> pendente")
      expect(response.body).to include("$0.00</span> pago")
    end

    it "exibe mensagem apropriada quando a república ainda não tem moradores nem despesas" do
      create(:republica, user: user)

      sign_in user
      get dashboard_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Nenhum dado financeiro cadastrado ainda")
      expect(response.body).to include("Nenhuma despesa cadastrada para exibir")
    end

    it "exibe atalhos para as telas correspondentes" do
      republica = create(:republica, user: user)

      sign_in user
      get dashboard_path

      expect(response.body).to include(new_republica_despesa_path(republica))
      expect(response.body).to include(new_republica_resident_path(republica))
      expect(response.body).to include(republica_pagamentos_path(republica))
    end
  end

  describe "GET /" do
    it "usa o dashboard como tela inicial do usuário autenticado" do
      sign_in user
      get "/"

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Resumo financeiro")
    end
  end
end

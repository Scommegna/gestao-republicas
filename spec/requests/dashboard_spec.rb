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
      create(:resident, republica: republica, active: true, name: "Ana")
      create(:resident, republica: republica, active: true, name: "Bia")
      create(:resident, republica: republica, active: false, name: "Carlos")
      aluguel = create(:despesa, republica: republica, descricao: "Aluguel junho", valor: 1000, vencimento: Date.current)
      create(:despesa, republica: republica, descricao: "Internet paga", valor: 150, vencimento: 2.days.ago.to_date)
      create(:despesa, republica: republica, descricao: "Energia futura", valor: 200, vencimento: 2.months.from_now.to_date)
      create(:pagamento, resident: republica.residents.active.first, despesa: aluguel, valor: 500, status: :paid)
      create(:despesa, republica: create(:republica), descricao: "Despesa de outra casa", valor: 999, vencimento: Date.current)

      sign_in user
      get dashboard_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Resumo financeiro")
      expect(response.body).to include("República Central")
      expect(response.body).to include("Aluguel junho")
      expect(response.body).to include("Internet paga")
      expect(response.body).to include("$650.00</span> pendente")
      expect(response.body).to include("$500.00</span> pago")
      expect(response.body).to include("Moradores ativos")
      expect(response.body).to include(">2</p>")
      expect(response.body).to include("$1,000.00")
      expect(response.body).to include("$1,350.00")
      expect(response.body).not_to include("Despesa de outra casa")
    end

    it "redireciona para a vitrine quando o usuário não participa de nenhuma república" do
      sign_in user
      get dashboard_path

      expect(response).to redirect_to(explore_republicas_path)
    end

    it "exibe o dashboard de uma república em que o usuário participa como membro" do
      republica = create(:republica, name: "República Vizinha")
      create(:resident, republica: republica, user: user, active: true)

      sign_in user
      get dashboard_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("República Vizinha")
      expect(response.body).to include("Você participa")
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
    it "usa o dashboard como tela inicial do usuário com república" do
      create(:republica, user: user)

      sign_in user
      get "/"

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Resumo financeiro")
    end

    it "leva o usuário sem república para a vitrine" do
      sign_in user
      get "/"

      expect(response).to redirect_to(explore_republicas_path)
    end
  end
end

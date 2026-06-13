# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Despesas", type: :request do
  let(:user) { create(:user, password: "123456", password_confirmation: "123456") }
  let(:republica) { create(:republica, user: user) }

  describe "GET /republicas/:republica_id/despesas" do
    it "redireciona visitante para login" do
      get republica_despesas_path(republica)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "lista despesas da república do usuário" do
      create(:despesa, republica: republica, descricao: "Internet fibra")

      sign_in user
      get republica_despesas_path(republica)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Internet fibra")
    end

    it "não permite acessar república de outro usuário" do
      outro = create(
        :user,
        phone: "31988882222",
        document: Faker::Number.unique.number(digits: 11).to_s,
        email: Faker::Internet.unique.email
      )
      rep_outra = create(:republica, user: outro)

      sign_in user
      get republica_despesas_path(rep_outra)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "fluxo CRUD" do
    before { sign_in user }

    it "cria, mostra, edita e remove uma despesa" do
      create(:resident, republica: republica, active: true)
      create(:resident, republica: republica, active: true)

      get new_republica_despesa_path(republica)
      expect(response).to have_http_status(:success)

      expect do
        post republica_despesas_path(republica), params: {
          despesa: {
            descricao: "Aluguel abril",
            valor: "1200.50",
            vencimento: "2026-06-10",
            categoria: "aluguel"
          }
        }
      end.to change(Despesa, :count).by(1)

      despesa = Despesa.order(:created_at).last
      expect(despesa.valor_por_morador).to eq(600.25)

      get republica_despesa_path(republica, despesa)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Aluguel abril")

      patch republica_despesa_path(republica, despesa), params: {
        despesa: { descricao: "Aluguel maio" }
      }
      expect(despesa.reload.descricao).to eq("Aluguel maio")

      expect do
        delete republica_despesa_path(republica, despesa)
      end.to change(Despesa, :count).by(-1)
    end

    it "não cria despesa inválida" do
      expect do
        post republica_despesas_path(republica), params: {
          despesa: { descricao: "", valor: "0", vencimento: "", categoria: "" }
        }
      end.not_to change(Despesa, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "não atualiza despesa inválida" do
      despesa = create(:despesa, republica: republica, valor: 100)

      patch republica_despesa_path(republica, despesa), params: { despesa: { valor: "0" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(despesa.reload.valor).to eq(100)
    end
  end

  describe "acesso não autorizado" do
    before { sign_in user }

    let(:outro_user) do
      create(
        :user,
        phone: "31988883333",
        document: Faker::Number.unique.number(digits: 11).to_s,
        email: Faker::Internet.unique.email
      )
    end
    let(:rep_outra) { create(:republica, user: outro_user) }

    it "não permite mostrar despesa de república de outro usuário" do
      despesa = create(:despesa, republica: rep_outra)

      get republica_despesa_path(rep_outra, despesa)

      expect(response).to have_http_status(:not_found)
    end

    it "não permite editar despesa de república de outro usuário" do
      despesa = create(:despesa, republica: rep_outra)

      get edit_republica_despesa_path(rep_outra, despesa)

      expect(response).to have_http_status(:not_found)
    end

    it "não permite atualizar despesa de república de outro usuário" do
      despesa = create(:despesa, republica: rep_outra, descricao: "Original")

      patch republica_despesa_path(rep_outra, despesa), params: { despesa: { descricao: "Invadida" } }

      expect(response).to have_http_status(:not_found)
      expect(despesa.reload.descricao).to eq("Original")
    end

    it "não permite remover despesa de república de outro usuário" do
      despesa = create(:despesa, republica: rep_outra)

      expect do
        delete republica_despesa_path(rep_outra, despesa)
      end.not_to change(Despesa, :count)
      expect(response).to have_http_status(:not_found)
    end
  end
end

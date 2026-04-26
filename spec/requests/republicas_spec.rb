require "rails_helper"

RSpec.describe "Republicas", type: :request do
  let(:user) { create(:user, password: "123456", password_confirmation: "123456") }

  describe "GET /republicas" do
    it "redireciona visitante para login" do
      get republicas_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "lista repúblicas do usuário autenticado" do
      rep = create(:republica, user: user, name: "Rep Alpha")

      sign_in user
      get republicas_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Rep Alpha")
    end
  end

  describe "fluxo CRUD" do
    before { sign_in user }

    it "cria, mostra, edita e remove uma república" do
      get new_republica_path
      expect(response).to have_http_status(:success)

      expect do
        post republicas_path, params: {
          republica: {
            name: "República Nova",
            endereco: "Rua X",
            descricao: "Descrição."
          }
        }
      end.to change(Republica, :count).by(1)

      republica = Republica.order(:created_at).last
      expect(response).to redirect_to(republica_path(republica))
      follow_redirect!

      get edit_republica_path(republica)
      expect(response).to have_http_status(:success)

      patch republica_path(republica), params: {
        republica: { name: "República Atualizada", endereco: "Rua Y", descricao: "Nova desc." }
      }
      expect(response).to redirect_to(republica_path(republica))
      expect(republica.reload.name).to eq("República Atualizada")

      expect do
        delete republica_path(republica)
      end.to change(Republica, :count).by(-1)

      expect(response).to redirect_to(republicas_url)
    end

    it "não permite acessar república de outro usuário" do
      outro = create(
        :user,
        phone: "31988881111",
        document: Faker::Number.unique.number(digits: 11).to_s,
        email: Faker::Internet.unique.email
      )
      rep_outra = create(:republica, user: outro)

      get republica_path(rep_outra)

      expect(response).to have_http_status(:not_found)
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Repúblicas — explorar e participar", type: :request do
  let(:user) { create(:user) }
  let(:owner) { create(:user) }

  describe "GET /republicas/explore" do
    it "redireciona visitante para login" do
      get explore_republicas_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "lista todas as repúblicas existentes" do
      create(:republica, user: owner, name: "República Central", tipo: "feminina")
      create(:republica, user: owner, name: "República do Morro", tipo: "masculina")

      sign_in user
      get explore_republicas_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("República Central")
      expect(response.body).to include("República do Morro")
    end

    it "filtra repúblicas pela busca" do
      create(:republica, user: owner, name: "República Central")
      create(:republica, user: owner, name: "República do Morro")

      sign_in user
      get explore_republicas_path, params: { q: "Morro" }

      expect(response.body).to include("República do Morro")
      expect(response.body).not_to include("República Central")
    end
  end

  describe "POST /republicas/:id/join" do
    it "cria o usuário como morador da república" do
      republica = create(:republica, user: owner)

      sign_in user
      expect do
        post join_republica_path(republica)
      end.to change { republica.residents.where(user: user).count }.by(1)

      expect(response).to redirect_to(dashboard_path(republica_id: republica.id))
      expect(user.participating?(republica)).to be(true)
    end

    it "não duplica a participação quando o usuário já participa" do
      republica = create(:republica, user: owner)
      create(:resident, republica: republica, user: user)

      sign_in user
      expect do
        post join_republica_path(republica)
      end.not_to(change { Resident.count })

      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe "DELETE /republicas/:id/leave" do
    it "remove a participação do usuário" do
      republica = create(:republica, user: owner)
      create(:resident, republica: republica, user: user)

      sign_in user
      expect do
        delete leave_republica_path(republica)
      end.to change { republica.residents.where(user: user).count }.by(-1)

      expect(response).to redirect_to(explore_republicas_path)
    end
  end
end

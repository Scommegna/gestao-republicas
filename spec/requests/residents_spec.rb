require "rails_helper"

RSpec.describe "Residents", type: :request do
  let(:user) { create(:user) }
  let(:republica) { create(:republica, user: user) }
  let(:valid_params) { { resident: { name: "João Silva", email: "joao@email.com", phone: "35999991234" } } }

  before do
    sign_in user
  end

  describe "GET /republicas/:republica_id/residents" do
    it "retorna sucesso" do
      get republica_residents_path(republica)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /republicas/:republica_id/residents/new" do
    it "retorna sucesso" do
      get new_republica_resident_path(republica)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /republicas/:republica_id/residents" do
    it "cria um morador com dados válidos" do
      expect {
        post republica_residents_path(republica), params: valid_params
      }.to change(Resident, :count).by(1)
      expect(response).to redirect_to(republica_residents_path(republica))
    end

    it "não cria morador sem nome" do
      expect {
        post republica_residents_path(republica), params: { resident: { name: "", email: "x@x.com" } }
      }.not_to change(Resident, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /republicas/:republica_id/residents/:id" do
    let(:resident) { create(:resident, republica: republica) }

    it "atualiza um morador" do
      patch republica_resident_path(republica, resident), params: { resident: { name: "Novo Nome" } }
      expect(resident.reload.name).to eq("Novo Nome")
      expect(response).to redirect_to(republica_residents_path(republica))
    end
  end

  describe "DELETE /republicas/:republica_id/residents/:id" do
    let!(:resident) { create(:resident, republica: republica) }

    it "remove um morador" do
      expect {
        delete republica_resident_path(republica, resident)
      }.to change(Resident, :count).by(-1)
      expect(response).to redirect_to(republica_residents_path(republica))
    end
  end

  describe "acesso não autorizado" do
    let(:outro_user) { create(:user) }
    let(:outra_republica) { create(:republica, user: outro_user) }

    it "não permite acessar moradores de república de outro usuário" do
      get republica_residents_path(outra_republica)
      expect(response).to have_http_status(:not_found)
    end
  end
end
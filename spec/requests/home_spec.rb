require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /home/index" do
    context "when signed in" do
      it "returns http success" do
        sign_in create(:user)
        get "/home/index"

        expect(response).to have_http_status(:success)
      end
    end

    context "when guest" do
      it "redirects to login" do
        get "/home/index"

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET / (root)" do
    context "when signed in" do
      it "shows the home page" do
        sign_in create(:user)
        get "/"

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Bem-vindo")
      end
    end

    context "when guest" do
      it "redirects to login" do
        get "/"

        expect(response).to redirect_to("/login")
      end
    end
  end
end

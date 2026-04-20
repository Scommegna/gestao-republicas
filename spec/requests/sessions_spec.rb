require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user, password: "123456", password_confirmation: "123456") }

  describe "POST /login" do
    it "signs in and redirects to home" do
      post user_session_path, params: {
        user: { email: user.email, password: "123456" }
      }

      expect(response).to redirect_to(authenticated_root_path)
      follow_redirect!
      expect(response.body).to include("Bem-vindo")
    end
  end

  describe "DELETE /logout" do
    it "signs out and sends user away from authenticated pages" do
      sign_in user

      delete destroy_user_session_path

      expect(response).to redirect_to(unauthenticated_root_path)

      get "/home/index"
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end

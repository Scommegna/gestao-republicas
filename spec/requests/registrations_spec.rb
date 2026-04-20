require "rails_helper"

RSpec.describe "Registrations", type: :request do
  describe "POST / (user registration)" do
    let(:attrs) do
      {
        user: {
          email: "morador_exemplo@example.com",
          password: "123456",
          password_confirmation: "123456",
          first_name: "Fulano",
          last_name: "Silva",
          phone: "35988887777",
          document: "12345678901"
        }
      }
    end

    it "creates an account with profile attributes" do
      expect do
        post user_registration_path, params: attrs
      end.to change(User, :count).by(1)

      created = User.order(:created_at).last
      expect(created.first_name).to eq("Fulano")
      expect(created.last_name).to eq("Silva")
      expect(created.phone).to eq("35988887777")
    end
  end
end

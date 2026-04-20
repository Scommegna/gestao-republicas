require "rails_helper"

RSpec.describe "home/index", type: :view do
  let(:user) { build(:user, first_name: "Maria") }

  before do
    allow(view).to receive_messages(current_user: user)
  end

  it "shows welcome message with first name" do
    render

    expect(rendered).to include("Maria")
    expect(rendered).to include("Sair")
  end
end

require "rails_helper"

RSpec.describe Republica, type: :model do
  describe "associações" do
    it "pertence a um usuário" do
      republica = create(:republica)
      expect(republica.user).to be_a(User)
    end

it "remove moradores e despesas dependentes ao ser removida" do
  republica = create(:republica)
  create(:resident, republica: republica)
  create(:despesa, republica: republica)

  expect { republica.destroy }.to change(Resident, :count).by(-1).and change(Despesa, :count).by(-1)
end
  end

  describe "validações" do
    it "exige nome" do
      republica = build(:republica, name: "")
      expect(republica).not_to be_valid
      expect(republica.errors[:name]).to include("can't be blank")
    end

    it "é válida com atributos da factory" do
      expect(build(:republica)).to be_valid
    end
  end
end

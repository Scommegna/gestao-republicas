require "rails_helper"

RSpec.describe Resident, type: :model do
  subject { build(:resident) }

  describe "validações" do
    it "é válido com atributos completos" do
      expect(subject).to be_valid
    end

    it "é inválido sem nome" do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it "é inválido sem email" do
      subject.email = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include("can't be blank")
    end

    it "é inválido com email em formato incorreto" do
      subject.email = "email-invalido"
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to be_present
    end

    it "é inválido com email duplicado na mesma república" do
      republica = create(:republica)
      create(:resident, email: "teste@email.com", republica: republica)
      novo_resident = build(:resident, email: "teste@email.com", republica: republica)
      expect(novo_resident).not_to be_valid
      expect(novo_resident.errors[:email]).to include("já cadastrado nesta república")
    end

    it "permite mesmo email em repúblicas diferentes" do
      create(:resident, email: "teste@email.com")
      subject.email = "teste@email.com"
      expect(subject).to be_valid
    end

    it "é inválido com telefone fora do formato" do
      subject.phone = "123"
      expect(subject).not_to be_valid
      expect(subject.errors[:phone]).to include("deve conter 10 ou 11 dígitos")
    end

    it "é válido sem telefone" do
      subject.phone = nil
      expect(subject).to be_valid
    end
  end

  describe "associações" do
    it "pertence a uma república" do
      expect(described_class.reflect_on_association(:republica).macro).to eq(:belongs_to)
    end
  end
end

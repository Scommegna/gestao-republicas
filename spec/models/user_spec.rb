# spec/models/user_spec.rb

require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'is invalid without first_name' do
      user.first_name = nil

      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include("can't be blank")
    end

    it 'is invalid without last_name' do
      user.last_name = nil

      expect(user).not_to be_valid
      expect(user.errors[:last_name]).to include("can't be blank")
    end

    it 'is invalid without document' do
      user.document = nil

      expect(user).not_to be_valid
      expect(user.errors[:document]).to include("can't be blank")
    end

    it 'is invalid without phone' do
      user.phone = nil

      expect(user).not_to be_valid
      expect(user.errors[:phone]).to include("can't be blank")
    end

    it 'is valid with 11 digit mobile phone' do
      user.phone = '35999999999'

      expect(user).to be_valid
    end

    it 'is valid with 10 digit landline phone' do
      user.phone = '3533334444'

      expect(user).to be_valid
    end

    it 'is invalid with letters' do
      user.phone = '35abc99999'

      expect(user).not_to be_valid
    end

    it 'is invalid with symbols' do
      user.phone = '(35)99999-9999'

      expect(user).not_to be_valid
    end

    it 'is invalid with less than 10 digits' do
      user.phone = '35999'

      expect(user).not_to be_valid
    end

    it 'is invalid with more than 11 digits' do
      user.phone = '359999999999'

      expect(user).not_to be_valid
    end

    it 'is invalid without email' do
      user.email = nil

      expect(user).not_to be_valid
    end

    it 'is invalid with duplicated email' do
      create(:user, email: user.email)

      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it 'is invalid with short password' do
      user.password = '12345'
      user.password_confirmation = '12345'

      expect(user).not_to be_valid
    end
  end

  describe 'callbacks' do
    it 'generates jti before create' do
      expect(user.jti).to be_nil

      user.save!

      expect(user.jti).to be_present
    end
  end

  describe 'enums' do
    it 'defaults role to user' do
      saved_user = create(:user)

      expect(saved_user.role).to eq('user')
      expect(saved_user.user?).to be true
    end

    it 'allows admin role' do
      admin = create(:user, role: :admin)

      expect(admin.role).to eq('admin')
      expect(admin.admin?).to be true
    end
  end

  describe ".jwt_revoked?" do
    let(:user) { create(:user) }

    it "returns false when payload jti matches the user" do
      payload = { "jti" => user.jti }

      expect(described_class.jwt_revoked?(payload, user)).to be false
    end

    it "returns true when payload jti does not match" do
      payload = { "jti" => SecureRandom.uuid }

      expect(described_class.jwt_revoked?(payload, user)).to be true
    end
  end

  describe ".revoke_jwt" do
    let(:user) { create(:user) }

    it "rotates jti so existing tokens become invalid" do
      previous = user.jti

      described_class.revoke_jwt({}, user)

      expect(user.reload.jti).not_to eq(previous)
    end
  end

  describe 'devise modules' do
    it 'responds to valid_password?' do
      expect(user).to respond_to(:valid_password?)
    end

    it 'validates correct password' do
      saved_user = create(:user, password: '123456', password_confirmation: '123456')

      expect(saved_user.valid_password?('123456')).to be true
      expect(saved_user.valid_password?('654321')).to be false
    end
  end
end

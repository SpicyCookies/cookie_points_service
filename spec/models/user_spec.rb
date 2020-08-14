# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:memberships) }
    it { should have_many(:organizations).through(:memberships) }
  end

  # TODO: TASK Refactor specs
  describe 'validations' do
    it 'has a valid factory' do
      expect(FactoryBot.build(:user)).to be_valid
    end

    context 'when email is invalid format' do
      let(:user_email) { 'testgmail.com' }

      it 'has invalid attribute' do
        expect(FactoryBot.build(:user, email: user_email)).not_to be_valid
      end
    end

    context 'when email is not provided' do
      let(:user_email) { '' }

      it 'has invalid attribute' do
        expect(FactoryBot.build(:user, email: user_email)).not_to be_valid
      end
    end

    context 'when a username that matches e-mail of another registered user' do
      let(:user_username) { 'testusername@gmail.com' }
      before do
        FactoryBot.create(:user, email: user_username)
      end

      it 'has invalid attribute' do
        expect(FactoryBot.build(:user, username: user_username)).not_to be_valid
      end
    end

    context 'when a duplicate username with different case' do
      let(:user_username) { 'testusername' }
      before do
        FactoryBot.create(:user, username: user_username.upcase)
      end

      it 'has invalid attribute' do
        expect(FactoryBot.build(:user, username: user_username)).not_to be_valid
      end
    end

    context 'when invalid username provided' do
      let(:user_username) { '[test] user-name?' }

      it 'has invalid attribute' do
        expect(FactoryBot.build(:user, username: user_username)).not_to be_valid
      end
    end

    context 'when username is not provided' do
      let(:user_username) { '' }

      it 'has invalid attribute' do
        expect(FactoryBot.build(:user, username: user_username)).not_to be_valid
      end
    end

    context 'when password is less than 6 characters' do
      let(:user_password) { 'a' * 5 }

      it 'has invalid attribute' do
        expect(FactoryBot.build(:user, password: user_password)).not_to be_valid
      end
    end

    context 'when password is over 256 characters long' do
      let(:user_password) { 'a' * 257 }

      it 'has invalid attribute' do
        expect(FactoryBot.build(:user, password: user_password)).not_to be_valid
      end
    end

    context 'when password is blank' do
      let(:user_password) { '' }

      it 'has invalid attribute' do
        expect(FactoryBot.build(:user, password: user_password)).not_to be_valid
      end
    end
  end
end

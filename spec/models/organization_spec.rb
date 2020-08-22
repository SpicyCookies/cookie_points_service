# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organization, type: :model do
  describe 'associations' do
    it { should have_many(:events).dependent(:destroy) }
    it { should have_many(:memberships).dependent(:destroy) }
    it { should have_many(:users).through(:memberships) }
  end

  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :total_members }
    it { should validate_presence_of :description }

    context 'with uniqueness' do
      # Reference shoulda-matcher documentation for "validate_uniqueness_of"
      # Populate attributes before calling Shoulda matcher
      subject { Organization.new(name: 'test_organization') }
      it { should validate_uniqueness_of(:name).case_insensitive }
    end
  end
end

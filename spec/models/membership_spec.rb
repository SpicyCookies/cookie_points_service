# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Membership, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:organization) }
  end

  describe 'validations' do
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :organization_id }

    context 'with uniqueness' do
      # Reference shoulda-matcher documentation for "validate_uniqueness_of"
      # Populate attributes before calling Shoulda matcher
      subject { Membership.new(user_id: 1, organization_id: 1) }

      it do
        should validate_uniqueness_of(:user_id)
          .case_insensitive
          .scoped_to(:organization_id)
      end

      it do
        should validate_uniqueness_of(:organization_id)
          .case_insensitive
          .scoped_to(:user_id)
      end
    end
  end
end

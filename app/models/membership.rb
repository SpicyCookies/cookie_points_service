# frozen_string_literal: true

class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  validates :user_id,
            :organization_id,
            presence: true,
            uniqueness: { case_sensitive: false }

  # TODO: TASK-4 Add events
  # TODO: TASK Add roles
end

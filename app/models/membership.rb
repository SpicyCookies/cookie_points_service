# frozen_string_literal: true

class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  validates :user_id,
            presence: true,
            uniqueness: {
              scope: :organization_id,
              case_sensitive: false
            }
  validates :organization_id,
            presence: true,
            uniqueness: {
              scope: :user_id,
              case_sensitive: false
            }

  # TODO: TASK-4 Add events
  # TODO: TASK Add roles
end

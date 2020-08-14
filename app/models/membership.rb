# frozen_string_literal: true

class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  # TODO: TASK-4 Add events
  # TODO: TASK Add roles
end

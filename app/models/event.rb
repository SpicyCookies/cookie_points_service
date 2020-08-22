# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :organization

  validates :organization_id, :name, :description, :start_time, :end_time,
            presence: true
end

# frozen_string_literal: true

class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false }
  validates :total_members, presence: true
  validates :description, presence: true
end

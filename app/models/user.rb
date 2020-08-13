# frozen_string_literal: true

class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :memberships
  has_many :organizations, through: :memberships

  validates :email, presence: true, uniqueness: true, email: true
  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: /\A[a-zA-Z0-9]+\Z/ } # Letters and numbers only
  validates :password,
            presence: true,
            length: { minimum: 6, maximum: 256 },
            if: -> { new_record? || crypted_password_changed? }

  def generate_jwt
    # TODO: TASK Set secret to ENV in production
    JWT.encode(
      {
        id: id,
        exp: 60.days.from_now.to_i # TODO: Set expiration
      },
      Rails.application.secrets.secret_key_base
    )
  end
end

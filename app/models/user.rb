# frozen_string_literal: true

class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :email, presence: true, uniqueness: true, email: true
  validates :username,
            presence: true,
            uniqueness: true,
            format: { with: /\A[a-zA-Z0-9]+\Z/ } # Letters and numbers only
  validates :password, length: { minimum: 6 }, on: :create

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

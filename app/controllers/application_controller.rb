# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ExceptionHandler

  # Handle AuthenticationErrors
  rescue_from Exceptions::AuthenticationError, with: :render_auth_error
  # Handle OrganizationErrors
  rescue_from Exceptions::OrganizationError::OrganizationNotFound, with: :render_not_found_error
  # Handle MembershipErrors
  rescue_from Exceptions::MembershipError::MembershipNotFound, with: :render_not_found_error

  private

  def authenticate!
    payload, _header = JWT.decode(token, Rails.application.secrets.secret_key_base)
    @current_user = User.find(payload['id'])
  rescue ActiveRecord::RecordNotFound => e
    error_msg = "Couldn't find user with id: #{payload['id']}"
    raise Exceptions::AuthenticationError::UserNotFound, "#{e.class}: #{error_msg}"
  rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError => e
    raise Exceptions::AuthenticationError::InvalidToken, "#{e.class}: #{e.message}"
  rescue StandardError => e
    raise Exceptions::AuthenticationError::InternalServerError, "#{e.class}: #{e.message}"
  end

  def current_user
    # TODO: Check case when both nil
    @current_user ||= authenticate!
  end

  def token
    request.headers['Authorization'].split(' ').last
  end
end

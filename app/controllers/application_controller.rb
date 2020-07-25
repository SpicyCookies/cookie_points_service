# frozen_string_literal: true

class ApplicationController < ActionController::API
  private

  def authenticate!
    payload, _header = JWT.decode(token, Rails.application.secrets.secret_key_base)
    @current_user = User.find_by(id: payload['id'])
  rescue StandardError
    head :unauthorized
  end

  def current_user
    @current_user ||= authenticate!
  end

  def token
    request.headers['Authorization'].split(' ').last
  end
end

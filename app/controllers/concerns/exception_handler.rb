# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern

  def render_auth_error(error)
    error_json = ExceptionBlueprint.render error, view: :exception, root: :error
    render json: error_json, status: :unauthorized
  end

  def render_not_found_error(error)
    error_json = ExceptionBlueprint.render error, view: :exception, root: :error
    render json: error_json, status: :not_found
  end
end

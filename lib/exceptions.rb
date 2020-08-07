# frozen_string_literal: true

module Exceptions
  #
  # Authentication exceptions
  #
  class AuthenticationError < StandardError
    class UserNotFound < AuthenticationError; end
    class InvalidToken < AuthenticationError; end
    class InternalServerError < AuthenticationError; end
  end
end

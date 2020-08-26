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

  # Organization exceptions
  class OrganizationError < StandardError
    class OrganizationNotFound < OrganizationError; end
  end

  # Membership exceptions
  class MembershipError < StandardError
    class MembershipNotFound < MembershipError; end
  end

  # Event exceptions
  class EventError < StandardError
    class EventNotFound < EventError; end
  end
end

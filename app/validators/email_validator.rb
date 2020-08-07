# frozen_string_literal: true

# Validates email format
# Source: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, (options[:message] || 'is not an email') unless
      value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  end
end

# frozen_string_literal: true

class UserBlueprint < Blueprinter::Base
  identifier :id

  view :created do
    fields :email, :username
    field(:token) do |_user, options|
      options[:token]
    end
  end

  view :normal do
    fields :email, :username, :created_at
  end
end

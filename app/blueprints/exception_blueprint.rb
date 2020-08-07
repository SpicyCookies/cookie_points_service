# frozen_string_literal: true

class ExceptionBlueprint < Blueprinter::Base
  view :exception do
    fields :class, :message
  end
end

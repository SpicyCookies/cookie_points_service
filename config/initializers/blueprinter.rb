# frozen_string_literal: true

Blueprinter.configure do |config|
  config.default_transformers = [BlueprinterTransformers::LowerCamelTransformer]
end

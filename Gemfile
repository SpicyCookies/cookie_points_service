source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3', '>= 6.0.3.2'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.4'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# JSON Object Presenter for Ruby that takes business objects and breaks them down into simple hashes and serializes them to JSON
gem 'blueprinter', '~> 0.25.0'
# Rails Engine that exposes your Swagger files as JSON endpoints
gem 'rswag-api', '~> 2.3.1'
# A stripped-down, bare-bones authentication library, with which you can write your own authentication flow
gem 'sorcery', '~> 0.15.0'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors', '~> 1.1.1'

group :development, :test do
  # Ruby on Rails vulnerability scanner
  gem 'brakeman', '~> 4.8.2'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console. For Windows support.
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Framework and DSL for defining and using factories - less error-prone, more explicit, and easier to work with than fixtures
  gem 'factory_bot_rails', '~> 6.1.0'
  # Mock data generator
  gem 'faker', '~> 2.13.0'
  # Adds step-by-step debugging and stack navigation capabilities to pry using byebug
  gem 'pry-byebug', '~> 3.9.0'
  # Ruby on Rails code testing tool
  gem 'rspec-rails', '~> 4.0.1'
  # Swagger-based DSL for rspec & accompanying rake task for generating Swagger files
  gem 'rswag-specs', '~> 2.3.1'
  # Ruby on Rails linter
  gem 'rubocop-rails', '~> 2.7.0'
end

group :development do
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

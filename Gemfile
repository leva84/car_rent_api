source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Ruby
ruby '3.1.3'
# Rails
gem 'rails', '~> 7.0.8', '>= 7.0.8.1'

gem 'active_model_serializers'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'rubocop', require: false

group :development do
  gem 'bullet'
end

group :development, :test do
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry'
end

group :test do
  gem 'rspec-rails', '~> 5.0'
end

source "https://rubygems.org"

gem "docker-template", "0.22.0"

group :development do
  gem 'envygeeks-rubocop'
  unless ENV["CI"] == "true"
    gem "travis"
    gem "pry"
  end
end

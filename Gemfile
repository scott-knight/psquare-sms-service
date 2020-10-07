source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

# ------ CORE -------
gem 'rails', '~> 6.0.3', '>= 6.0.3.3'
gem 'pg'
gem 'puma'

# ------ CORE SUPPORTIVE -------
gem 'bootsnap', '>= 1.4.2', require: false
gem 'bundler-audit'
gem 'discard'
gem 'faraday'
gem 'hamlit' # for email layouts - https://github.com/k0kubun/hamlit
gem 'hamlit-rails'
gem 'pagy' # https://github.com/ddnexus/pagy - fast pagination
gem 'pg_search'
gem 'rack-cors'
gem 'rainbow'

# ------ Queuing -------
gem 'sidekiq'

# ------ SERIALIZATION -------------------
gem 'jsonapi-serializer' # https://github.com/jsonapi-serializer/jsonapi-serializer
gem 'oj'


group :development do
  gem 'foreman'
  gem 'html2haml'
  gem 'letter_opener'
  gem 'listen'
  gem 'meta_request'
end

group :development, :test do
  gem 'factory_bot_rails'
  gem 'faker', git: 'https://github.com/stympy/faker.git', branch: 'master'
  gem 'mock_redis'
  gem 'rspec-rails'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'timecop'
  gem 'webmock'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'rspec-sidekiq'
  gem 'shoulda-matchers'
  gem 'simplecov'
end
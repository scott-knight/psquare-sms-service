source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

gem 'rails', '~> 6.0.3', '>= 6.0.3.3'
gem 'pg'
gem 'puma'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'bundler-audit'
gem 'discard'
gem 'hamlit' # for email layouts - https://github.com/k0kubun/hamlit
gem 'hamlit-rails'
gem 'pagy' # https://github.com/ddnexus/pagy - fast pagination
gem 'rack-cors'

# ------ SERIALIZATION -------------------
gem 'fast_jsonapi'
gem 'oj'


group :development do
  gem 'html2haml'
  gem 'letter_opener'
  gem 'listen'
  gem 'meta_request'
  gem 'squasher'
end

group :development, :test do
  gem 'factory_bot_rails'
  gem 'faker', git: 'https://github.com/stympy/faker.git', branch: 'master'
  gem 'rspec-rails'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'timecop'
  gem 'webmock'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'shoulda-matchers'
  gem 'simplecov'
end
# frozen_string_literal: true
source "https://rubygems.org"

gem "sinatra"
gem 'sinatra-contrib'
gem 'activerecord'
gem 'sinatra-activerecord'
gem 'rake'

gem 'haml'
gem 'sass'
gem 'coffee-script'

group :production do
  #gem 'mysql'
end

group :development, :test do
  gem "thin"
  gem 'rack-test'
  gem 'sqlite3'
  gem 'tux'
end

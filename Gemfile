source 'https://rubygems.org'

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter'
  gem 'jdbc-sqlite3'
  gem 'jruby-openssl'
end

platforms :ruby, :mswin, :mingw do
  gem 'sqlite3'
end


group :development, :test do
  gem 'autotest-notification'
  gem 'rspec-rails'
  gem 'json', '~> 1.7.7'
end

group :test do
  gem 'capybara'
  gem 'systemu'
  gem 'simplecov'
  gem 'factory_girl_rails'
  gem 'faker'
end

gemspec

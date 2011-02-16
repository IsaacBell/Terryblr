source "http://rubygems.org"

gemspec

gem "rails", "~> 3.0"
gem "devise"
gem "memcached"
gem "aasm"

if RUBY_VERSION < '1.9'
  gem "ruby-debug"
end


group :development do
  gem "bundler", "~> 1.0"
end

group :development, :test do
  gem "rcov", ">= 0"
  gem "rspec-rails", "~> 2.5"
  gem "sqlite3-ruby", :require => "sqlite3"
  gem "capybara", "~> 0.4"
  gem "webrat"
end

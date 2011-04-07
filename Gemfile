# reference: http://yehudakatz.com/2010/12/16/clarifying-the-roles-of-the-gemspec-and-gemfile/

source "http://rubygems.org"
gemspec

gem "aws-s3",  :require => "aws/s3"
gem "gattica", :git => "http://github.com/mathieuravaux/gattica.git"

group :development, :test do
  # gem 'capybara', :git => "https://github.com/jnicklas/capybara.git"
  gem 'capybara'
  gem 'awesome_print'
end

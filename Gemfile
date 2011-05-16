# reference: http://yehudakatz.com/2010/12/16/clarifying-the-roles-of-the-gemspec-and-gemfile/

source "http://rubygems.org"
gemspec

gem "aws-s3",  :require => "aws/s3"
gem "gattica", :git => "http://github.com/mathieuravaux/gattica.git"
gem "dropbox"
gem "eventmachine", ">=  1.0.0.beta.1"
gem "thin"

gem "em-http-request", :git => "git://github.com/mathieuravaux/em-http-request.git"
gem "em-net-http", :git => "git://github.com/mathieuravaux/em-net-http.git"
# gem "disqussion", :path => "../disqussion"

group :development, :test do
  gem 'capybara'
  gem 'awesome_print'
  gem 'thin'
  gem 'growl'
  gem 'ruby-growl'
end

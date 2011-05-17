# reference: http://yehudakatz.com/2010/12/16/clarifying-the-roles-of-the-gemspec-and-gemfile/

source "http://rubygems.org"
gemspec

gem "aws-s3",  :require => "aws/s3"
gem "dropbox"
gem "eventmachine", ">=  1.0.0.beta.1"
gem "thin"

gem "analytical", :git => "git://github.com/mathieuravaux/analytical.git"
gem "gattica", :git => "http://github.com/mathieuravaux/gattica.git"
gem "em-http-request", :git => "git://github.com/mathieuravaux/em-http-request.git"
gem "em-net-http", :git => "git://github.com/mathieuravaux/em-net-http.git"
gem "em-synchrony", :git => "git://github.com/igrigorik/em-synchrony.git"

group :development, :test do
  gem 'capybara'
  gem 'awesome_print'
  gem 'thin'
  gem 'growl'
  gem 'ruby-growl'
end

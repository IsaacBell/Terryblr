# reference: http://yehudakatz.com/2010/12/16/clarifying-the-roles-of-the-gemspec-and-gemfile/

source "http://rubygems.org"
gemspec

gem "aws-s3",  :require => "aws/s3"
gem "gattica", :git => "http://github.com/mathieuravaux/gattica.git"
gem "dropbox" #, :git => "https://github.com/mathieuravaux/dropbox.git"
# gem "dropbox", :path => "../dropbox"

gem "em-http-request", :git => "git://github.com/mathieuravaux/em-http-request.git"
gem "em-net-http", :git => "git://github.com/mathieuravaux/em-net-http.git"
# gem "disqussion", :path => "../disqussion"

group :development, :test do
  # gem 'capybara', :git => "https://github.com/jnicklas/capybara.git"
  gem 'capybara'
  gem 'awesome_print'
  gem 'thin'
end

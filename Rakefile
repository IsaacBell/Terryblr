# encoding: UTF-8
require 'rubygems'
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rake'
require 'rake/rdoctask'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Terryblr'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb'] - FileList['spec/dummy/vendor/plugins/resource_controller/generators/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:spec_html) do |spec|
  mkdir_p 'tmp/spec'
  spec.pattern = FileList['spec/**/*_spec.rb'] - FileList['spec/dummy/vendor/plugins/resource_controller/generators/**/*_spec.rb']
  spec.rspec_opts = '--format html --out tmp/spec/index.html'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

# Terryblr::Application.load_tasks
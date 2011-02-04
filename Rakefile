# encoding: UTF-8
require 'rubygems'
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rake'
require 'rake/rdoctask'

require 'rake/testtask'
require File.join(File.dirname(__FILE__), 'lib', 'terryblr', 'version')


Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task :default => :test

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Terryblr'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = "terryblr"
    gem.version = Terryblr::VERSION.dup
    gem.summary = "CMS Engine for Rails 3"
    gem.files = Dir["{lib}/**/*", "{app}/**/*", "{config}/**/*"]
  end
rescue
  puts "Jeweler or one of its dependencies is not installed."
end

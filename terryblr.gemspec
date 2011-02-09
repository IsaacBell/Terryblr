# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'terryblr/version'

Gem::Specification.new do |s|
  s.name        = "terryblr"
  s.version     = Terryblr::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Lachlan Laycock", "Samuel Mendes", "Mathieu Raveaux", "Jérémy Van de Wyngaert"]
  s.email       = ["bonjour@aimele88.com"]
  s.homepage    = "http://aimele88.com"
  s.summary     = "KISS Content Management System"
  s.description = "Terryblr is an engine providing a CMS following a KISS principle"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "rspec"
  s.add_dependency "devise"

  s.files = Dir["{lib}/**/*", "{app}/**/*", "{config}/**/*"] + ["LICENSE", "README.rdoc"]
end

require 'inherited_resources'
require 'haml'
require 'formtastic'
require 'settingslogic'
require 'will_paginate'
require 'acts_as_commentable'
require 'validates_email_format_of'
require 'jammit'
require 'barista'
require "dropbox"

require 'cancan'
# TODO: pull request in CanCan
module CanCan
  # For use with Inherited Resources
  class InheritedResource < ControllerResource # :nodoc:
    # defer this directly to Inherited Resources
    def load_collection
      @controller.send(:collection)
    end

    def resource_instance=(instance)
    end

    # def resource_instance
    #   @controller.send(:resource) if load_instance?
    # end

    def collection_instance=(instance)
    end

    def collection_instance
      @controller.send :collection
    end
  end
end

require File.expand_path('terryblr/engine', File.dirname(__FILE__)) if defined?(Rails) && Rails::VERSION::MAJOR == 3

require "acts-as-taggable-on"
require "money"
require "paperclip"
require "dynamic_form"
require "gattica"
require "delayed_job"
require 'mini_fb'

[ 'terryblr/configuration',
  'terryblr/extendable',
  'terryblr/cache_system',
  'terryblr/validators',
  'terryblr/time_formats',
  'terryblr/formtastic_builder',
  "terryblr/cache_system",
  "terryblr/i18n_helpers",
  'terryblr/base/base',
  'terryblr/base/taggable',
  'terryblr/base/aasmstates',
  'terryblr/base/validation',
].each do |path|
  require File.expand_path(path, File.dirname(__FILE__))
end

module Terryblr
  class << self
    
    # Modify configuration
    # Example:
    #   Terryblr.configure do |config|
    #     config.user_model = 'MyUser'
    #   end
    def configure
      yield configuration
    end
    
    # Accessor for Terryblr::Configuration
    def configuration
      @configuration ||= Configuration.new
    end
    alias :config :configuration
    
  end
end
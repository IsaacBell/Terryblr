require File.expand_path('terryblr/engine', File.dirname(__FILE__)) if defined?(Rails) && Rails::VERSION::MAJOR == 3

[ 'terryblr/configuration',
  'terryblr/memcached_system',
  'terryblr/models/base',
  'terryblr/models/page',
  '../app/models/terryblr/page'
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

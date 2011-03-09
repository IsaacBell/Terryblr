require "rails"

require "terryblr/cache_system"
require "terryblr/i18n_helpers"
require "terryblr/flash_session_cookie_middleware"
require "terryblr/base/base"
require "terryblr/base/aasmstates"
require "terryblr/base/taggable"
require "terryblr/base/validation"

module Terryblr
  class Engine < Rails::Engine
    paths["db/migrate"] = 'db/migrate'

    # Since the database can't be set up when running the generators,
    # we move the models path to autoload instead of eager_load.
    # otherwise, we would get "could not find table 'xxxx'" exceptions.
    config.eager_load_paths -= [ paths["app/models"].first ]
    config.autoload_paths << paths["app/models"].first

    config.gem 'devise'
    config.gem 'cancan'
    
    # Add flash uploader session detection middleware
    initializer :add_flash_middleware, :before => :load_application_initializers do |app|
      config.app_middleware.insert_before(Warden::Manager, FlashSessionCookieMiddleware, ::Settings.session_key)
    end

    
    rake_tasks do
      load 'terryblr/railties/tasks.rake'
    end
  end
end

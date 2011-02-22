require "rails"

require "terryblr/memcached_system"
require "terryblr/i18n_helpers"
require "terryblr/base/base"
require "terryblr/base/aasmstates"
require "terryblr/base/taggable"

module Terryblr
  class Engine < Rails::Engine
    paths["db/migrate"] = 'db/migrate'

    rake_tasks do
      load 'terryblr/railties/tasks.rake'
    end
  end
end

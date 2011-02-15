require "rails"

require "terryblr/memcached_system"
require "terryblr/base/base"
require "terryblr/base/aasmstates"

module Terryblr
  class Engine < Rails::Engine
    rake_tasks do
      load "terryblr/railties/tasks.rake"
    end
  end
end

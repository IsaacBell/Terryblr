require "rails"

require "terryblr/memcached_system"
require "terryblr/models/base"
require "terryblr/models/page"


module Terryblr
  class Engine < Rails::Engine
    rake_tasks do
      load "terryblr/railties/tasks.rake"
    end
  end
end

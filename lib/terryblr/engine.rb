require "rails"

module Terryblr
  class Engine < Rails::Engine
    rake_tasks do
      load "terryblr/railties/tasks.rake"
    end
  end
end

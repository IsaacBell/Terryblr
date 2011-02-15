require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record/migration'

module Terryblr
  module Generators
    class TerryblrGenerator < Rails::Generators::Base
      namespace "terryblr"
      include Rails::Generators::Migration

      def self.source_root
        @source_root ||= File.join(File.dirname(__FILE__), '..', 'templates')
      end

      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname)
        next_migration_number = current_migration_number(dirname) + 1
        if ActiveRecord::Base.timestamped_migrations
          [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % next_migration_number].max
        else
          "%.3d" % next_migration_number
        end
      end

      def install_dependencies
        plugin 'resource_controller', :git => 'git://github.com/anupamc/resource_controller.git'
      end

      def create_migration_file
        migration_template 'create_pages.rb', 'db/migrate/create_pages.rb'
      end

      def create_configuration_file
        copy_file 'initializer.rb', 'config/initializers/terryblr.rb'
      end
    end
  end
end

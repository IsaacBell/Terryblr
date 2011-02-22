require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record/migration'

# TODO: add a command to run: script/rails generate acts_as_taggable_on:migration

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

      def create_migration_file
        migration_template 'create_videos.rb', 'db/migrate/create_videos.rb'
        migration_template 'create_photos.rb', 'db/migrate/create_photos.rb'
        migration_template 'create_orders.rb', 'db/migrate/create_orders.rb'
        migration_template 'create_posts.rb', 'db/migrate/create_posts.rb'
        migration_template 'create_pages.rb', 'db/migrate/create_pages.rb'
        migration_template 'create_messages.rb', 'db/migrate/create_messages.rb'
        migration_template 'create_likes.rb', 'db/migrate/create_likes.rb'
        migration_template 'create_comments.rb', 'db/migrate/create_comments.rb'
        migration_template 'create_features.rb', 'db/migrate/create_features.rb'
        migration_template 'create_products.rb', 'db/migrate/create_products.rb'
        migration_template 'create_line_items.rb', 'db/migrate/create_line_items.rb'
      end

      def create_configuration_file
        copy_file 'initializer.rb', 'config/initializers/terryblr.rb'
        copy_file 'settings.yml', 'config/settings.yml'
      end
    end
  end
end

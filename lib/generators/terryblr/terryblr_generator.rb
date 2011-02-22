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

      def create_migration_file
        generate('acts_as_taggable_on:migration')
        generate('delayed_job')
        %w(videos photos orders posts pages likes comments messages features products line_items links votes tweets).each do |f|
          src = "create_#{f}.rb"
          dst = "db/migrate/#{src}"
          migration_template src, dst
        end
      end

      def create_configuration_file
        copy_file 'initializer.rb', 'config/initializers/terryblr.rb'
        copy_file 'settings.yml', 'config/settings.yml'
        
        # Static assets
        copy_dir_contents 'public', 'public'
      end
      
      private
      
      def copy_dir_contents(source_dir, target_dir)
        base_dir = File.join(File.dirname(__FILE__), '../templates', source_dir)
        raise "Base dir not found: #{base_dir}" unless Dir.exists?(base_dir)
        Dir.new(base_dir).each do |file|
          next if %w(. .. .DS_Store).include?(file)
          
          base_path = File.join(base_dir, file)
          source_path = File.join(source_dir, file)
          target_path = File.join(target_dir, file)
          
          if File.directory?(base_path)
            # Recurse into dir
            copy_dir_contents(source_path, File.join(target_dir, file))
          else
            # Copy files
            copy_file base_path, target_path
          end
        end
      end
      
    end
  end
end

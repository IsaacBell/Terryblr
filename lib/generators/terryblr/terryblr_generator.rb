require 'rails/generators/active_record'

module Terryblr
  module Generators
    class TerryblrGenerator < ActiveRecord::Generators::Base
      namespace "terryblr"

      def self.source_root
        @source_root ||= File.join(File.dirname(__FILE__), 'templates')
      end

      def run_devise_install
        generate("devise:install") 
        generate(:devise, name)
      end

      def create_migration_file
        migration_template 'migration.rb', "db/migrate/add_is_admin_to_#{table_name}.rb"
      end
    end
  end
end

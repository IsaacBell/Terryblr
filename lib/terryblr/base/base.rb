module Terryblr
  class Base < ActiveRecord::Base

    #
    # Class definitions
    #
    self.abstract_class = false

    self.instance_eval do
      # Prevent the table name from being called 'bases'
      def table_name
        @table_name ||= self.name.split('::').last.tableize
      end
    end

    #
    # Callbacks
    #
    before_validation :update_slug

    def update_slug
      # Set slug if not set
      if respond_to?(:slug) and respond_to?(:title)
        self.slug = title? ? title.parameterize : id if !slug? or slug.match(/^\d+$/)
      end
    end
  end
end

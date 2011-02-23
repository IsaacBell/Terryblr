module Terryblr
  class Base < ActiveRecord::Base
    module Validation
      def self.included(recipient)
        recipient.class_eval do
          before_validation :update_slug
          def update_slug
            # Set slug if not set
            if respond_to?(:slug) and respond_to?(:title)
              self.slug = title? ? title.parameterize : id if !slug? or slug.match(/^\d+$/)
            end
          end
        end
      end
    end
  end
end

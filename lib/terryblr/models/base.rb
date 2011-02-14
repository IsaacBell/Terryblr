#
# Common base class common to all Terryblr models
#
module Terryblr
  module Models
    class Base < ActiveRecord::Base

      self.abstract_class = true

      def before_save
        self.created_at = Time.now if respond_to?(:created_at) and self.created_at.nil?
        self.updated_at = Time.now if respond_to?(:updated_at)
      end

      def before_create
        self.created_at = Time.now if respond_to?(:created_at)
      end

    end
  end
end

#
# Common base class common to all Terryblr models
#
module Terryblr
  module Models
    class Base < ActiveRecord::Base

      self.abstract_class = true

      before_create :create_timestamp
      before_save :update_timestamps

      def update_timestamps
        self.created_at = Time.now if respond_to?(:created_at) and self.created_at.nil?
        self.updated_at = Time.now if respond_to?(:updated_at)
      end

      def create_timestamp
        self.created_at = Time.now if respond_to?(:created_at)
      end

    end
  end
end

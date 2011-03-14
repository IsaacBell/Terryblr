module Terryblr
  class Base < ActiveRecord::Base

    #
    # Includes
    #
    include ActiveModel::Validations

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
  
    def fix_tiny_mce
      # Fix broken paths from TinyMCE
      self.body = body.gsub(%r{src=\"(.*)/system/images/}, "src=\"/system/images/") if body?
    end
  
    def to_param
      return slug.to_s if self.respond_to?(:slug) and !slug.blank?
      return "#{id}-#{name.to_s.parameterize}" if self.respond_to?(:name) and self.name?
      return "#{id}-#{title.to_s.parameterize}" if self.respond_to?(:title) and self.title?
      id.to_s
    end

    def dom_id(prefix=nil)
      display_id = new_record? ? "new" : id
      prefix ||= self.class.name
      prefix != :bare ? "#{prefix.to_s.parameterize('_')}_#{display_id}" : display_id
    end

  end
end

require 'terryblr/base/aasmstates'

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
    # Behvaiours / Mixins
    #
    include Terryblr::Base::AasmStates
    
    # acts_as_taggable
    # acts_as_taggable_on Settings.tags[self.table_name]['groups'] if defined?(Settings.tags[self.table_name]['groups'])
    # named_scope :tagged, lambda { |tags|
    #   tags_sql = tags.is_a?(Array) ? tags.map{|t|"'#{t}'"}.join(",") : "'#{tags}'"
    #   { 
    #     :joins => "JOIN taggings ON taggings.taggable_id = #{table_name}.id AND taggings.taggable_type = '#{self.to_s}'", 
    #     :group => "#{table_name}.id",
    #     :conditions =>  "taggings.tag_id in (SELECT id from tags where name IN (#{tags_sql}))"
    #   }
    # }
    

    #
    # Callbacks
    # 
    def before_save
      self.created_at = Time.now if respond_to?(:created_at) and self.created_at.nil?
      self.updated_at = Time.now if respond_to?(:updated_at)
    end

    def before_create
      self.created_at = Time.now if respond_to?(:created_at)
    end
    
    def before_validation
      # Set slug if not set
      if respond_to?(:slug) and respond_to?(:title)
        self.slug = title? ? title.parameterize : id if !slug? or slug.match(/^\d+$/)
      end
    end
    
    #
    # 
    #
    
  end
end
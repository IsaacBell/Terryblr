module Terryblr
  class Base < ActiveRecord::Base
    module Taggable
      def self.included(recipient)
        recipient.class_eval do
          # Throws errors if table doesn't exist on first project setup
          if recipient.table_exists?
            acts_as_taggable

            Settings.load! # Needed for dev env when reloading class caches
            
            if defined?(Settings.tags[self.table_name]) && defined?(Settings.tags[self.table_name]['groups'])
              acts_as_taggable_on Settings.tags[self.table_name]['groups']
              scope :tagged, lambda { |tags|
                tags_sql = tags.is_a?(Array) ? tags.map{|t|"'#{t}'"}.join(",") : "'#{tags}'"
                select("#{table_name}.*").
                joins("JOIN taggings ON taggings.taggable_id = #{table_name}.id AND taggings.taggable_type IN ('#{self.sti_names.join("','")}')").
                where("taggings.tag_id in (SELECT id from tags where LOWER(name) IN (#{tags_sql.downcase}))")
              }
            end
          end
        end
      end
    end
  end
end
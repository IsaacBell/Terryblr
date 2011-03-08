module Terryblr
  class Base < ActiveRecord::Base
    module Taggable
      def self.included(recipient)
        recipient.class_eval do
          # Throws errors if table doesn't exist on first project setup
          if recipient.table_exists?
            acts_as_taggable

            #XXX Seems this is needed to make the tagging work :-S
            #XXX Maybe better like this? Settings.tags.send(self.table_name).send(:groups)
            Settings.tags[self.table_name]['groups'].inspect
            if defined?(Settings.tags[self.table_name]['groups'])
              acts_as_taggable_on Settings.tags[self.table_name]['groups']
              scope :tagged, lambda { |tags|
                tags_sql = tags.is_a?(Array) ? tags.map{|t|"'#{t}'"}.join(",") : "'#{tags}'"
                joins("JOIN taggings ON taggings.taggable_id = #{table_name}.id AND taggings.taggable_type = '#{self.to_s}'").
                group("#{table_name}.id").
                where("taggings.tag_id in (SELECT id from tags where name IN (#{tags_sql}))")
              }
            end
          end
        end
      end
    end
  end
end
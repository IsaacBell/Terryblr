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
  end
end

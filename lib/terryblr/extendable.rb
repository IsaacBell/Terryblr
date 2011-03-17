module Terryblr
    module Extendable
      extend ActiveSupport::Concern

      included do |base|
        base.class_exec {
          public
          Terryblr.configuration.inject_overrides base
        }
      end
    end
end

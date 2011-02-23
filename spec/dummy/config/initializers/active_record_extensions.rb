require 'digest/md5'

module ActiveRecord

  class Base
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

  module Timestamp
    def soft_touch(attribute = nil, validate = true)
      current_time = current_time_from_proper_timezone

      if attribute
        write_attribute(attribute, current_time)
      else
        write_attribute('updated_at', current_time) if respond_to?(:updated_at)
        write_attribute('updated_on', current_time) if respond_to?(:updated_on)
      end

      save(validate)
    end
  end

  module Validations
    module ClassMethods
      def validates_url_format_of(*attr_names)
        configuration = { :on => :save, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix }
        configuration.update(attr_names.extract_options!)
        validates_each(attr_names,configuration) do |record, attr_name, value|
          next if value.blank?
          begin
            if value !~ configuration[:with]
              record.errors.add(attr_name, 'is not a valid url format.')
              next
            end
            uri = URI.parse(value)
            unless uri.class == URI::HTTP or uri.class == URI::HTTPS
              record.errors.add(attr_name, 'must be an HTTP or HTTPS protocol format')
            end
          rescue URI::InvalidURIError
            record.errors.add(attr_name, 'is not a valid url.')
          end
        end
      end
    end
  end

  module Timestamp
    private
      def current_time_from_proper_timezone
        self.class.default_timezone == :utc ? Time.now.utc : Time.zone.now
      end
  end

  #XXX class XmlSerializer < ActiveRecord::Serialization::Serializer
  #XXX   def add_procs
  #XXX     if procs = options.delete(:procs)
  #XXX       [ *procs ].each do |proc|
  #XXX         proc.call(*(proc.arity > 1 ? [options, @record] : [options]))
  #XXX       end
  #XXX     end
  #XXX   end
  #XXX end
end
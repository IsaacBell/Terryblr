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

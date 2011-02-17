require 'unicode_utils'

module Terryblr
  module I18nHelpers
    def self.included( recipient )
      puts "Terryblr::I18nHelpers included !!"
      recipient.class_eval do
        def terryblr_translate *args
          options = args.extract_options!
          scope_ = options.fetch(:scope, [])
          puts "ttt: #{args[0]}, scope_: #{scope_.inspect}"
          if args[0].to_s.starts_with?('.') && scope_.include?('terryblr')
            puts "already correctly scoped"
            args << options
            I18n.translate(*args)
          else
            puts "re-scoping"
            raise "NotImplemented" unless scope_.empty?
            options[:scope] = 'terryblr'
            args << options
            I18n.translate(*args)
          end
        end

        def capitalize(str)
          str.sub str.first, UnicodeUtils.upcase(str.first, I18n.locale)
        end

        def terryblr_translate_capitalize(*args)
          capitalize terryblr_translate(*args)
        end

        def terryblr_translate_titleize(*args)
          if I18n.locale == :en
            UnicodeUtils.titlecase terryblr_translate(*args), I18n.locale
          else
            capitalize terryblr_translate(*args)
          end
        end

        alias :tt :terryblr_translate
        alias :ttc :terryblr_translate_capitalize
        alias :ttt :terryblr_translate_titleize

        if recipient.respond_to? :helper_method
          helper_method :terryblr_translate, :terryblr_translate_capitalize, :terryblr_translate_titleize
          helper_method :tt, :ttc, :ttt
        end
      end
    end
  end
end

module ActionView
  module Helpers
    module TranslationHelper
      include Terryblr::I18nHelpers
    end
  end
end
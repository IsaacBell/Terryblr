require 'digest/sha1'

module Terryblr
  module CacheSystem
    protected

    #
    # Caching. Override in controller if need specific behaviour
    #
    def pre_cache
      # Only cache is request is a get, there is no caching enabled and no flash message
      return unless request.get? and ActionController::Base.perform_caching

      unless cache_content.blank?
        # Make sure the right headers are sent out for IE
        respond_to do |wants|
          wants.html {
            render :text => cache_content
          }
          wants.js {
            render :text => cache_content
          }
          wants.xml {
            render :text => cache_content
          }
          unless request.env['HTTP_USER_AGENT'] =~ /msie/i # IE Sends fucked up 'Accept' headers and wants.any breaks
            wants.any {
              render :text => cache_content
            }
          end
        end
        return false
      end
    end

    def post_cache
      # Write response body to the cache if required.
      if response.status>=200 and response.status<300 and cache_content.blank?
        Rails.cache.write(memcached_cache_key, response.body)
      end
    end

    # Override this if other valuables are needed
    def cache_key
      "#{request.url}/#{request.format.to_sym.to_s}/#{flash.to_s.gsub(/\W/,'')}"
    end

    def memcached_cache_key
      Digest::SHA1.hexdigest(cache_key)
    end

    def cache_content
      @cache_content ||= Rails.cache.fetch(memcached_cache_key) 
    # rescue Memcached::ServerIsMarkedDead => exc
    #   return nil
    end
  end
end
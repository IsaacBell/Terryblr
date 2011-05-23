require 'digest/sha1'

module Terryblr

  # 
  # Provides a general cache system for the application
  # Caching. Override in controller if need specific behaviour
  # 
  module CacheSystem
    protected
    
    # 
    # Use as an around filter for requests that are to be cached. The entire response is stored in the cache-storage.
    # _cache_key_ is used to determine the key to cache the content. Caching is only used on GET requests which respons with a success code and when _perform_caching_ is enabled.
    #
    def cache
      # Only cache request if it's a get and caching is active.
      return yield unless request.get? and ActionController::Base.perform_caching

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
      
      else
        # Execute the request
        yield

        # Write response body to the cache if required.
        if response.status>=200 and response.status<300
          Rails.cache.write(memcached_cache_key, response.body)
        end
      end
    end

    # Compute a cache key from the request path and format
    # Override this if other valuables are needed
    # @return a string used as the cache key for the request
    def cache_key
      "#{request.path}/#{request.format.to_sym.to_s}/#{flash.to_s.gsub(/\W/,'')}"
    end

    # Hash the cache key with SHA1 to create new key used in memcached
    # @return an SHA1 hex digest of the cache key
    def memcached_cache_key
      Digest::SHA1.hexdigest(cache_key)
    end

    # Fetch the content for the current cache key
    # @return the content associated with the cache key of the current request
    def cache_content
      @cache_content ||= Rails.cache.fetch(memcached_cache_key) 
    # rescue Memcached::ServerIsMarkedDead => exc
    #   return nil
    end
  end
end

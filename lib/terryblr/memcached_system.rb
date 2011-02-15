module Terryblr
  module MemcachedSystem
    protected

    #
    # Caching. Override in controller if need specific behaviour
    #
    def cache
      # Only cache is request is a get, there is no caching enabled and no flash message
      yield and return unless request.get? and ActionController::Base.perform_caching

      if cache_content
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
        return
      else
        yield
        Rails.cache.write(memcached_cache_key, response.body) if response.status[0..2]=="200"
      end
    end

    # Override this if other valuables are needed
    def cache_key
      "#{request.url}/#{request.format.to_sym.to_s}/#{flash.to_s.gsub(/\W/,'')}"
    end

    def memcached_cache_key
      cache_key[0..(250-Rails.env.size-2)]
    end

    def cache_content
      @content ||= Rails.cache.fetch(memcached_cache_key) 
    rescue Memcached::ServerIsMarkedDead => exc
      return nil
    end
  end
end
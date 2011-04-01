class Terryblr::ApplicationController < ActionController::Base
  include Terryblr::CacheSystem
  helper 'terryblr/application'
  #helper_method :current_user_session, :current_user

  before_filter :work_around_rails_middleware_bug

  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  private

  def work_around_rails_middleware_bug
    request.env["action_dispatch.request.parameters"] = nil
    request.env["action_dispatch.request.formats"] = nil
    request.env["action_dispatch.request.accepts"] = nil
    request.env["action_dispatch.request.content_type"] = nil
    params.merge! request.params
    params.merge! request.params.symbolize_keys
    request.parameters[:format] = params[:format]
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def cache_key
    "#{request.url}/#{request.format.to_sym.to_s}/#{etag}/#{flash.to_s.gsub(/\W/,'')}"
  end

  def set_expires
    expires_in 30.seconds, :private => false, :public => true
  end

  def set_fresh_when
    if ActionController::Base.perform_caching and collection?
      return !stale?(:etag => etag, :last_modified => last_modified, :public => true)
    end
  end

  def etag
    last_modified.to_i
  end

  LAST_MODIFIED_CACHE_KEY = 'site_last_modified'.freeze

  def last_modified
    # Update the cache last-modified date
    set_last_modified(true) unless @last_modified ||= Rails.cache.read(LAST_MODIFIED_CACHE_KEY)
    @last_modified
  end

  def set_last_modified(force = false)
    # Don't update it unless forced to or the if the request is just a GET
    @last_modified = Time.now.utc
    Rails.cache.write(LAST_MODIFIED_CACHE_KEY, @last_modified) if force or !request.get?
  end

  def resource?
    respond_to?(:resource, true) and !resource.nil?
  end

  def collection?
    respond_to?(:collection, true) and !collection.nil? and !collection.empty?
  end

  def current_ability
    @current_ability ||= Terryblr::Ability.new(current_user)
  end
end

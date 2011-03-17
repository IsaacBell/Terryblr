class Terryblr::ApplicationController < ResourceController::Base

  include Terryblr::CacheSystem
  helper 'terryblr/application'
  #helper_method :current_user_session, :current_user

  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  private

  #def current_user_session
  #  return @current_user_session if defined?(@current_user_session)
  #  @current_user_session = UserSession.find
  #end
  #
  #def current_user
  #  return @current_user if defined?(@current_user)
  #  @current_user = current_user_session && current_user_session.record
  #end
  #
  #def require_user
  #  unless current_user
  #    store_location
  #    flash[:notice] = "You must be logged in to access this page"
  #    redirect_to new_user_session_path
  #    return false
  #  end
  #end

  #def require_no_user
  #  if current_user
  #    store_location
  #    flash[:notice] = "You must be logged out to access this page"
  #    redirect_to user_path(current_user)
  #    return false
  #  end
  #end
  
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
    @last_modified = Rails.cache.write(LAST_MODIFIED_CACHE_KEY, Time.now.utc) if force or !request.get?
  end

  def object?
    respond_to?(:object, true) and !object.nil?
  end

  def collection?
    respond_to?(:collection, true) and !collection.nil? and !collection.empty?
  end

  def current_ability
    @current_ability ||= Terryblr::Ability.new(current_user)
  end

  include Terryblr::Extendable
end

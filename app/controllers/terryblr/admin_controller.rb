class Terryblr::AdminController < Terryblr::ApplicationController

  inherit_resources
  def self.inherited(base)
    super
    resource_class_name = base.name.sub(/Admin::/, '').sub(/Controller/, '').singularize
    base.resource_class = resource_class_name.constantize
  end

  load_and_authorize_resource :class => resource_class
  
  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.info "AdminController: CanCan::AccessDenied #{exception.inspect}, admin?: #{current_user && !current_user.admin?}; #{current_user.inspect}"
    if current_user && !current_user.admin?
      @message = exception.message
      render 'admin/common/access_denied'
    else
      redirect_to new_user_session_path, :notice => exception.message
    end
  end

  before_filter :set_date, :only => [:index, :filter]
  before_filter :set_expires, :only => [:analytics]
  around_filter :cache, :only => [:analytics]
  skip_before_filter :verify_authenticity_token, :only => [:analytics]
  after_filter :set_last_modified

  layout 'admin'

  private
  
  def current_site
    # Use session as key for 
    @current_site ||= if session[:site_name]
      Terryblr::Site.find_by_name(session[:site_name])
    elsif !request.subdomains.empty?
      Terryblr::Site.find_by_name(request.subdomains.last)
    else
      Terryblr::Site.default
    end
    session[:site_name] = @current_site.name
    @current_site
  end

  def set_expires
    expires_in (last_modified+6.hours), :private => false, :public => true
    fresh_when(:etag => last_modified.utc.to_i, :last_modified => last_modified.utc, :public => true)
  end

  def last_modified
    case controller_name
    when 'admin_home'
      now = Time.now
      mod = now.hour%6
      last_modified = (now-mod.hours).change(:min => 0, :sec => 0, :usec => 0)
    else
      super
    end
  end

  def set_date
    @date ||= if params[:month] || params[:year]
      "1-#{params[:month]}-#{params[:year] || Date.today.year}".to_date rescue Date.today
    else
      Date.today
    end
  end
end
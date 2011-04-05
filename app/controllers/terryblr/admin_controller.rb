class Terryblr::AdminController < Terryblr::ApplicationController

  unloadable

  #XXX load_and_authorize_resource - Removed as causing too much trouble.
  
  rescue_from CanCan::AccessDenied do |exception|
    if current_user && !current_user.admin?
      @message = exception.message
      render 'admin/common/access_denied'
      # raise exception
    else
      redirect_to new_user_session_path, :notice => exception.message
    end
  end

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

  def object_url
    send("#{url_name}_path", object)
  end

  def collection_url
    send("#{url_name.pluralize}_path")
  end

  def url_name
    ctrl_parts = params[:controller].split('/')
    ctrl_parts.delete("terryblr")
    ctrl_parts.join('_').singularize
  end
  alias_method :route_name, :url_name

  def admin_model_name
    ctrl_name = params[:controller].split('/').last.strip
    "Terryblr::#{ctrl_name.singularize.camelize}"
  end
  
  def resource_name
    admin_model_name.demodulize.downcase
  end
  
  def object_name
    admin_model_name.split('::').join('_').downcase
  end

  def end_of_association_chain
    assoc_name = params[:controller].split('/').last.strip.to_sym
    if current_site.respond_to?(assoc_name)
      current_site.send(assoc_name)
    else
      admin_model_name.constantize
    end
  end

  def object
    @object ||= end_of_association_chain.find_by_slug(params[:id]) || end_of_association_chain.find(params[:id])
  end
  
  def build_object
    @object ||= begin
      # puts "end_of_association_chain: #{end_of_association_chain.inspect}"
      new_obj = if end_of_association_chain.respond_to? :pending
        end_of_association_chain.pending.first
      else
        end_of_association_chain.first
      end
      if new_obj
        new_obj.attributes = object_params
        new_obj
      else
        end_of_association_chain.new(object_params)
      end
    end
  end

  def collection
    conditions = "state = '#{params[:state] || 'published'}'"
    unless params[:search].blank?
      search_str = "%#{params[:search].downcase}%"
      conditions = ["#{conditions} AND (LOWER(title) like ? OR LOWER(state) like ?)", search_str, search_str]
    end
    @collection ||= end_of_association_chain.paginate(:conditions => conditions, :order => "published_at desc, created_at desc", :page => params[:page])
  end

  def set_date
    @date ||= if params[:month] || params[:year]
      "1-#{params[:month]}-#{params[:year] || Date.today.year}".to_date rescue Date.today
    else
      Date.today
    end
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

end

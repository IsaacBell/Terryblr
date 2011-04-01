class Terryblr::AdminController < Terryblr::ApplicationController

  inherit_resources
  def self.inherited(base)
    super
    resource_class_name = base.name.sub(/Admin::/, '').sub(/Controller/, '').singularize
    base.resource_class = resource_class_name.constantize
  end

  # NOTE: authorize access to /users/new before doing what you are about to do with that next line
  #  => didn't understand ??
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
    admin_model_name.constantize
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
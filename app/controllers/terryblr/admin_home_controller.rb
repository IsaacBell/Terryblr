class Terryblr::AdminHomeController < Terryblr::ApplicationController
  layout 'admin'

  inherit_resources

  after_filter :set_last_modified
  before_filter :set_date, :only => [:index, :filter]
  before_filter :set_expires, :only => [:analytics]
  skip_before_filter :verify_authenticity_token, :only => [:analytics]
  around_filter :cache, :only => [:analytics]

  before_filter :ensure_terryblr_setup, :only => [:index, :search]
  before_filter :setup_only_once!, :only => [:setup, :setup!]

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.info "AdminHomeController: CanCan::AccessDenied #{exception.inspect}, admin?: #{current_user && !current_user.admin?}; #{current_user.inspect}"
    if current_user && !current_user.admin?
      @message = exception.message
      render 'admin/common/access_denied'
    else
      redirect_to new_user_session_path, :notice => exception.message
    end
  end

  def collection
    nil
  end

  def setup
    @user = Terryblr::User.new
  end
  def setup!
    @user = Terryblr::User.new params[:user]
    @user.admin = true
    if @user.save
      sign_in @user
      redirect_to :admin
    else
      render "setup"
    end
  end


  def index
    if cannot? :read, Terryblr::Tweet
      raise CanCan::AccessDenied
    end
    @show_as_dash = true
    index!
  end

  def analytics
    @since = 1.month.ago.to_date
    # Visitors
    gs = Gattica.new({:email => Settings.ganalytics.email, :password => Settings.ganalytics.password, :profile_id => Settings.ganalytics.profile_id})
    @reports = {
      :visitors => {
        :dimensions => %w(day),
        :metrics => %w(visits)
      },
      :top_referrers => {
        :dimensions => %w(source),
        :metrics => %w(visits),
        :sort => %w(-visits)
      },
      :top_landing_pages => {
        :dimensions => %w(landingPagePath),
        :metrics => %w(uniquePageviews),
        :sort => %w(-uniquePageviews)
      }
    }
    @reports.each do |k, v|
      v[:results] = gs.get(v.update({ :start_date => @since.to_s, :end_date => Date.today.to_s}))
    end

    # Twitter mentions
    # Group by the date of the tweet
    @tweets = Terryblr::Tweet.analytics(@since)
    @tweet_exposure = Terryblr::Tweet.exposure(@since)
    @tweet_reach = Terryblr::Tweet.reach(@since)
  end

  def search
    raise CanCan::AccessDenied if cannot?(:read, Terryblr::Post) || cannot?(:read, Terryblr::Page)

    @query = params[:search].to_s.strip
    like_q = "%#{@query}%".downcase
    conds  = ["LOWER(state) like ? or LOWER(body) like ? or LOWER(title) like ?", like_q, like_q, like_q]
    tag    = Terryblr::Tag.find_by_name(@query)
    joins  = nil
    @results = {
      :posts    => end_of_association_chain.where(conds).paginate(:page => 1),
      :pages    => current_site.pages.where(conds).paginate(:page => 1)
    }
    respond_to do |wants|
      wants.html {
       render :action => "terryblr/admin_home/search"
      }
    end
  end
  
  def switch_site
    # Set current-site if param matches an existing one
    if s = Terryblr::Site.find_by_name(params[:site])
      @current_site = s
      session[:site_name] = s.name
    end
    flash[:notice] = t('terryblr.terryblr.admin_home.switch_site.site_changed', :current_site => current_site.name)
    redirect_to request.env["HTTP_REFERER"] || admin_path
  end

  private

  def set_date
    @date ||= if params[:month] || params[:year]
      "1-#{params[:month]}-#{params[:year] || Date.today.year}".to_date rescue Date.today
    else
      Date.today
    end
  end

  def end_of_association_chain
    current_site.posts
  end

  def ensure_terryblr_setup
    if terryblr_setup?
      true
    else
      redirect_to :terryblr_setup
      false
    end
  end

  def setup_only_once!
    raise "Terryblr is already set up !" if terryblr_setup?
  end

  include Terryblr::Extendable
end
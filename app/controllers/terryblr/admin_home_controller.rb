class Terryblr::AdminHomeController < Terryblr::AdminController

  skip_before_filter :load_and_authorize_resource

  def collection
    nil
  end

  index {
    before {
      raise CanCan::AccessDenied if cannot? :read, Terryblr::Tweet
    }
    wants.html {
      @show_as_dash = true
    }
  }

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

  def end_of_association_chain
    current_site.posts
  end

  include Terryblr::Extendable

end

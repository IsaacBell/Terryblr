class Terryblr::HomeController < Terryblr::PublicController

  helper 'terryblr/posts'

  caches_page :robots
  before_filter :collection, :only => [:index, :sitemap]

  def search
  end

  def sitemap
    @posts = collection
    @countdowns = live_posts.tagged_with('countdown').limit(500)
    @pages = Terryblr::Page.published.limit(500)
    respond_to do |wants|
      wants.xml
    end
  end

  def robots
    respond_to do |wants|
      wants.txt
    end
  end

  def error
    respond_to do |wants|
      wants.html {
        render "terryblr/errors/500"
      }
    end
  end

  def not_found
    respond_to do |wants|
      wants.html {
        render "terryblr/errors/404"
      }
    end
  end

  private

  def collection
    @collection ||= case action_name
      when 'sitemap'
        live_posts.limit(500).order("updated_at desc")
      when 'index'
        live_posts.paginate :page => params[:page]
      else
        []
      end
  end

  def live_posts
    Terryblr::Post.live
  end

  include Terryblr::Extendable
end
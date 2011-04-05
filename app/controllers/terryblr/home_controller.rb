class Terryblr::HomeController < Terryblr::PublicController

  helper 'terryblr/posts'
  
  caches_page :robots
  before_filter :collection, :only => [:index, :sitemap]
  
  index {
    before {
      @posts = collection
    }
    wants.html
    wants.js
  }

  def search
  end

  def sitemap
    @posts = collection
    @countdowns = current_site.posts.live.tagged_with('countdown').limit(500)
    @pages = current_site.pages.published.limit(500)
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

  def collection
    @collection ||= case action_name
      when 'sitemap'
        current_site.posts.live.all(:limit => 500, :order => "updated_at desc")
      when 'index'
        current_site.posts.live.paginate(:page => params[:page])
      else
        []
      end
  end

  include Terryblr::Extendable
end
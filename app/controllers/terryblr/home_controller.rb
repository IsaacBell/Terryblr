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
    @countdowns = Terryblr::Post.live.tagged_with('countdown').all(:limit => 500)
    @pages = Terryblr::Page.published.all(:limit => 500)
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
        Terryblr::Post.live.all(:limit => 500, :order => "updated_at desc")
      when 'index'
        Terryblr::Post.live.paginate(:page => params[:page])
      else
        []
      end
  end

end
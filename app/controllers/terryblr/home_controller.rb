class Terryblr::HomeController < Terryblr::PublicController

  helper 'terryblr/posts'
  
  caches_page :robots
  
  index {
    before {
      @posts = collection
    }
    wants.html
    wants.js {
      render :update do |page|
        page.replace "#more_posts_btn", :partial => "terryblr/posts/list"
      end
    }
  }

  def search
  end

  def robots
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
    @collection ||= Post.published.paginate(:page => params[:page])
  end

end
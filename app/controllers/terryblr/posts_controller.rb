class Terryblr::PostsController < Terryblr::PublicController
  before_filter :date, :only => [:index]
  before_filter :object, :only => [:gallery_params, :show, :next, :previous]
  before_filter :featured_pics, :only => [:show]
  before_filter :collection, :only => [:index, :tagged, :archives]
  before_filter :require_user, :only => [:preview]
  skip_before_filter :set_expires, :only => [:preview]

  index {
    wants.rss {}
  }

  show {
    before {
      @page_title = object.title rescue nil
    }
    wants.xml {
      render "terryblr/common/slideshow"
    }
    failure.wants.html {
      raise ActiveRecord::RecordNotFound
    }
  }

  def preview
    @object = Post.find(params[:id])
    @object.published_at = Time.zone.now
    @body_classes = "posts-show" # So that CSS will think it's the details page
    respond_to do |wants|
      wants.html {
        render :action => "show"
      }
    end
  end

  def archives
    @page_title = 'Archives'
    respond_to do |wants|
      wants.html
      wants.js {
        render :update do |page|
          page.replace "pagination", :partial => "archives", :locals => { :posts => @collection }
        end
      }
    end
  end

  def tagged
    @page_title = "Posts tagged #{params[:tag]}"
    respond_to do |wants|
      wants.html {
        render :action => "terryblr/posts/tagged", 
      }
      wants.js {
        render :update do |page|
          page.replace "#more_posts_btn", :partial => "list"
        end
      }
    end
  end

  def next
    post = object.next || object
    redirect_to post_path(post, post.slug)
  end

  def previous
    post = object.previous || object
    redirect_to post_path(post, post.slug)
  end

  private

  def object
    @post = @object ||= posts_chain.find_by_id(params[:id])        || 
                        posts_chain.find_by_slug(params[:slug])    || # Needed to keep permalinks alive
                        posts_chain.find_by_slug(params[:id])      || # Needed to keep permalinks alive
                        posts_chain.find_by_tumblr_id(params[:id]) || # Needed to keep permalinks alive
                        (raise ActiveRecord::RecordNotFound)
  end

  def featured_pics
    @featured_pics ||= Feature.live.tagged_with('sidebar')
  end

  def collection
    @posts = @collection ||= case self.action_name 
    when 'index'
      if !params[:search].blank?
        # Normal post listing
        @query = params[:search]
        q = "%#{@query}%"
        posts_chain.all(
          :conditions => ["title like ? or body like ?", q, q]
        ).paginate(:page => params[:page])
      else
        # Normal post listing
        posts_chain.paginate(:page => params[:page])
      end

    when 'tagged'
      posts_chain.tagged_with(params[:tag]).paginate(:page => params[:page])

    when 'archives'
      col = :published_at
      conditions = if params[:month] and params[:year]
        @date = Date.parse("#{params[:year]}-#{params[:month]}-1")
        ["EXTRACT(MONTH from #{col}) = ? and EXTRACT(YEAR from #{col}) = ?", @date.month, @date.year]
      else
        []
      end

      posts_chain.paginate(
        :page => params[:page],
        :conditions => conditions,
        :order => "#{col} desc, created_at desc")

    else
      []
    end
  end

  def date
    @date ||= "1-#{params[:month]}-#{params[:year] || Date.today.year}".to_date rescue Date.today
  end

  def posts_chain
    Post.live
  end
end

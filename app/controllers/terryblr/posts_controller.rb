class Terryblr::PostsController < Terryblr::PublicController
  before_filter :date, :only => [:index]
  before_filter :resource, :only => [:gallery_params, :show, :next, :previous]
  before_filter :featured_pics, :only => [:show]
  before_filter :collection, :only => [:index, :tagged, :archives]
  before_filter :require_user, :only => [:preview]
  skip_before_filter :set_expires, :only => [:preview]

  def index
    super do |wants|
      wants.atom
      wants.rss
    end
  end

  def show
    @page_title = resource.title rescue nil
    super do |wants|
      wants.xml   { render "terryblr/common/slideshow" }
    end
  end

  def preview
    @post = current_site.posts.find(params[:id])
    @post.published_at = Time.zone.now
    @body_classes = "posts-show" # So that CSS will think it's the details page
    respond_to do |wants|
      wants.html { render :action => "show" }
    end
  end

  def archives
    @page_title = 'Archives'
    respond_to do |wants|
      wants.html { render :action => "terryblr/posts/archives" }
      wants.js   { render :action => "terryblr/posts/archives" }
    end
  end

  def tagged
    @page_title = "Posts tagged #{params[:tag]}"
    respond_to do |wants|
      wants.html { render :action => "terryblr/posts/tagged" }
      wants.js
    end
  end

  def next
    post = resource.next || resource
    redirect_to post_path(post, post.slug)
  end

  def previous
    post = resource.previous || resource
    redirect_to post_path(post, post.slug)
  end

  private

  def featured_pics
    @featured_pics ||= current_site.features.live.tagged_with('sidebar')
  end

  def resource
    @post ||= end_of_association_chain.find_by_id(params[:id])        || 
              end_of_association_chain.find_by_slug(params[:slug])    || # Needed to keep permalinks alive
              end_of_association_chain.find_by_slug(params[:id])      || # Needed to keep permalinks alive
              end_of_association_chain.find_by_tumblr_id(params[:id]) # Needed to keep permalinks alive
  end

  def collection
    @posts ||= case self.action_name
    when 'index'
      if !params[:search].blank?
        # Normal post listing
        @query = params[:search]
        q = "%#{@query}%"
        end_of_association_chain.all(
          :conditions => ["title like ? or body like ?", q, q]
        ).paginate(:page => params[:page])
      else
        # Normal post listing
        end_of_association_chain.paginate(:page => params[:page])
      end

    when 'tagged'
      end_of_association_chain.select("DISTINCT posts.id, posts.*").tagged_with(params[:tag]).paginate(:page => params[:page])

    when 'archives'
      col = :published_at
      conditions = if params[:month] and params[:year]
        @date = Date.parse("#{params[:year]}-#{params[:month]}-1")
        ["EXTRACT(MONTH from #{col}) = ? and EXTRACT(YEAR from #{col}) = ?", @date.month, @date.year]
      else
        []
      end
      paginate(
        :page => params[:page],
        :conditions => conditions,
        :order => "#{col} desc, created_at desc")
    else
      []
    end
  end

  def featured_pics
    @featured_pics ||= Terryblr::Feature.live.tagged_with('sidebar')
  end

  def begin_of_association_chain
    current_site
  end

  def end_of_association_chain
    Terryblr::Post.live
  end
  
  def date
    @date ||= "1-#{params[:month]}-#{params[:year] || Date.today.year}".to_date rescue Date.today
  end

  include Terryblr::Extendable
end
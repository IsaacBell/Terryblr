class Terryblr::PostsController < Terryblr::PublicController

  before_filter :date, :only => [:index]
  before_filter :resource, :only => [:gallery_params, :show, :next, :previous]
  before_filter :featured_pics, :only => [:show]
  before_filter :collection, :only => [:index, :tagged, :archives]

  def index
    super do |wants|
      wants.atom
      wants.rss
    end
  end

  def show
    @page_title = resource.title rescue nil
    track_resource_analytics

    super do |wants|
      wants.xml   { render "terryblr/common/slideshow" }
    end
  end

  def preview
    @post = end_of_association_chain.new(params[:post])
    @post.id ||= 0
    @post.published_at = 1.minute.ago
    @post.slug = 'preview' unless @post.slug?
    @body_classes = "posts-show" # So that CSS will think it's the details page
    respond_to do |wants|
      wants.html { render :template => "terryblr/posts/show" }
    end
  end

  def archives
    @page_title = 'Archives'
    respond_to do |wants|
      wants.html { render "terryblr/posts/archives" }
      wants.js   { render "terryblr/posts/archives" }
    end
  end

  def tagged
    @page_title = "Posts tagged #{params[:tag]}"
    respond_to do |wants|
      wants.html { render "terryblr/posts/tagged" }
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

  def begin_of_association_chain
    current_site
  end

  def end_of_association_chain
    current_site.posts.live
  end

  def resource
    @post ||= end_of_association_chain.find_by_id(params[:id])        || 
              end_of_association_chain.find_by_slug(params[:slug])    || # Needed to keep permalinks alive
              end_of_association_chain.find_by_slug(params[:id])      || # Needed to keep permalinks alive
              end_of_association_chain.find_by_tumblr_id(params[:id]) # Needed to keep permalinks alive
  end

  def collection
    @per_page ||= 5 
    @posts ||= case self.action_name
    when 'index'
      if !params[:search].blank?
        # Normal post listing
        @query = params[:search]
        q = "%#{@query}%"
        end_of_association_chain.all(
          :conditions => ["title like ? or body like ?", q, q]
        ).paginate(:page => params[:page], :per_page => @per_page)
      else
        # Normal post listing
        end_of_association_chain.paginate(:page => params[:page], :per_page => @per_page)
      end

    when 'tagged'
      end_of_association_chain.select("DISTINCT posts.id, posts.*").tagged_with(params[:tag]).paginate(:page => params[:page], :per_page => @per_page)

    when 'archives'
      col = :published_at
      conditions = if params[:month] and params[:year]
        @date = Date.parse("#{params[:year]}-#{params[:month]}-1")
        ["EXTRACT(MONTH from #{col}) = ? and EXTRACT(YEAR from #{col}) = ?", @date.month, @date.year]
      else
        []
      end
      end_of_association_chain.paginate(
        :page => params[:page],
        :per_page => @per_page,
        :conditions => conditions,
        :order => "#{col} desc, created_at desc")
    else
      []
    end
  end
  
  def date
    @date ||= "1-#{params[:month]}-#{params[:year] || Date.today.year}".to_date rescue Date.today
  end

  include Terryblr::Extendable
end

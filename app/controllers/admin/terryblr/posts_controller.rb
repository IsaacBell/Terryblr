class Admin::Terryblr::PostsController < Terryblr::AdminController

  before_filter :collection, :only => [:index, :filter]

  def index
    @show_as_dash = true
    super do |wants|
      wants.js    { render :template => "admin/terryblr/posts/index" }
      wants.html  { render :template => "admin/terryblr/posts/index" }
    end
  end

  def filter
    @show_as_dash = true
    respond_to do |wants|
      wants.html { render :template => "admin/terryblr/posts/index" }
    end
  end

  def new
    @post = end_of_association_chain.new(
      :post_type => post_type,
      :published_at => nil,
      :twitter_id => nil,
      :slug => nil)
    super
  end

  def edit
    super do |wants|
      wants.html { render :template => "admin/terryblr/posts/edit" }
    end
  end

  def create
    super do |success, failure|
      success.html { redirect_to admin_posts_path }
      failure.html { render :template => "admin/terryblr/posts/edit" }
    end
  end

  def update
    super do |success, failure|
      success.html {
        if params[:post] and params[:post][:state]=="publish_now"
          flash[:notice] += " <b>Your post is now live!</b>"
        end
        redirect_to admin_posts_path
      }
    end
  end

  def show
    super do |wants|
      wants.html { redirect_to edit_admin_post_path(@post) }
    end
  end

  def destroy
    super do |wants|
      wants.html { redirect_to admin_posts_path }
    end
  end

  private

  def post_type
    @post_type ||= begin
      if params.has_key?(:type)
        params[:type].downcase.singularize
      else
        'post'
      end
    end
  end

  def collection
    scope = case params[:state]
      when "drafted"
        col = :updated_at
        end_of_association_chain.drafted
      else
        col = :published_at
        end_of_association_chain.published
    end
    if params[:month] and params[:year]
      @date = Date.parse("#{params[:year]}-#{params[:month]}-1")
      scope = scope.for_month @date, col
    end
    @posts = @collection ||= scope.order("#{col} desc, created_at desc").paginate(:page => (params[:page] || 1))
  end

  include Terryblr::Extendable
end
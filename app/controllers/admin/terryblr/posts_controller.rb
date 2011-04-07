class Admin::Terryblr::PostsController < Terryblr::AdminController
  before_filter :post_type, :only => [:new]

  def index
    show_as_dash
    super do |wants|
      wants.html { render :template => "admin/terryblr/posts/index" }
    end
  end

  def new
    resource.post_type = post_type
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
        if params[:post] and params[:post][:state] == "publish_now"
          flash[:notice] += " <b>Your post is now live!</b>"
        end
        redirect_to admin_posts_path
      }
    end
  end

  def show
    super do |wants|
      wants.html { redirect_to edit_admin_post_path resource }
    end
  end

  def destroy
    super do |wants|
      wants.html { redirect_to admin_posts_path }
    end
  end

  private

  def show_as_dash
    @show_as_dash ||= true
  end

  def post_type
    @post_type ||= begin
      if params.has_key?(:type) && Terryblr::Post::post_types.include?(params[:type].downcase)
        params[:type].downcase
      else
        'post'
      end
    end
  end

  def resource
    @post ||= begin
      if params[:id]
        end_of_association_chain.find_by_slug(params[:id]) || 
        end_of_association_chain.find_by_id(params[:id])
      else
        end_of_association_chain.new
      end
    end
  end

  def collection
    @posts ||= begin
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
      scope.order("#{col} desc, created_at desc").paginate(:page => (params[:page] || 1))
    end
  end

  include Terryblr::Extendable
end
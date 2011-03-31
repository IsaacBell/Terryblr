class Admin::Terryblr::PagesController < Terryblr::AdminController

  prepend_before_filter :find_page

  def index
    @list_cols = %w(page state)
    @action_cols = %w(add_child)
    super
  end

  def new
    # Create post!
    @page = Terryblr::Page.new
    @page.save!
    @page.state = :published
    @page.parent_id = params[:parent_id].to_i if params[:parent_id]
    super do |wants|
      wants.html { render :action => "edit" }
    end
  end

  def show
    super do |wants|
      wants.html { redirect_to admin_pages_path }
    end
  end

  def create
    super do |success, failure|
      success.html { redirect_to admin_pages_path }
    end
  end

  def update
    super do |success, failure|
      success.html { redirect_to admin_pages_path }
    end
  end

  private

  def find_page
    @page = Terryblr::Page.find_by_slug(params[:id]) || Terryblr::Page.find_by_id(params[:id])
  end

  def collection
    order = "created_at desc"
    @collection = @posts ||= if params[:parent_id]
      Terryblr::Page.by_state(params[:state] || 'published').all(:conditions => {:parent_id => params[:parent_id]}, :order => order)
    else
      Terryblr::Page.roots.by_state(params[:state] || 'published').all(:order => order)
    end
  end

  include Terryblr::Extendable
end
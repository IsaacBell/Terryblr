class Admin::Terryblr::PagesController < Terryblr::AdminController

  def index
    @list_cols = %w(page state)
    @action_cols = %w(add_child)
    super
  end

  def show
    super do |wants|
      wants.html { redirect_to admin_pages_path }
    end
  end

  def new
    # Create post!
    resource.save!
    resource.state = :published
    resource.parent_id = params[:parent_id].to_i if params[:parent_id]
    super do |wants|
      wants.html { render :action => "edit" }
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

  def resource
    @page ||= begin
      if params[:id]
        end_of_association_chain.find_by_slug(params[:id]) || end_of_association_chain.find_by_id(params[:id])
      else
        end_of_association_chain.new
      end
    end
  end

  def collection
    order = "created_at desc"
    @pages ||= if params[:parent_id]
      end_of_association_chain.by_state(params[:state] || 'published').where(:parent_id => params[:parent_id])
    else
      end_of_association_chain.roots.by_state(params[:state] || 'published')
    end.order(order)
  end

  include Terryblr::Extendable
end
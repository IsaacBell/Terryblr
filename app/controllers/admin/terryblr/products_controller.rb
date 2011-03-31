class Admin::Terryblr::ProductsController < Terryblr::AdminController

  def new
    # Create post!
    resource.save!
    resource.state = :published
    super do |wants|
      wants.html { render :action => "edit" }
    end
  end

  def show
    super do |wants|
      wants.html { redirect_to edit_admin_product_path(resource) }
    end
  end

  def update
    # Set display_order
    if params[:product].key?(:sizes_attributes)
      i = 0
      params[:product][:sizes_attributes].each{|s| s[:display_order] = (i+=1) }
    end
    
    # Set product price
    params[:product][:price] = params[:product][:price].to_money
    
    # Mark as destroyed if not included in the list
    object.sizes.each do |s|
      unless params[:product][:sizes_attributes].map(&:id).include?(s.id)
        params[:product][:sizes_attributes] << {:id => s.id, :_destroy => true}  
      end
    end
  end

  private

  include Terryblr::Extendable
end
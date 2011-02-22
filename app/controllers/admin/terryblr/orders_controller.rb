class Admin::Terryblr::OrdersController < Terryblr::AdminController

  helper 'terryblr/admin', 'admin/terryblr/orders'
  before_filter :find_by_month, :only => [:filter]

  show {
    wants.html {
      redirect_to edit_admin_order_path(object)
    }
  }
  
  def filter
    respond_to do |wants|
      wants.html {
        render :action => "index"
      }
    end
  end
  

  private
  
  def collection
    conditions = ""
    unless params[:search].blank?
      search_str = "%#{params[:search].downcase}%"
      fields = %w(first_name last_name zip country city province)
      search_sql = fields.map {|f| "LOWER(#{f}) like ?" }.join(' OR ')
      conditions = [search_sql] + fields.size.times.map{|i| search_str }
    end
    @collection ||= end_of_association_chain.all(:conditions => conditions, :order => "created_at desc").paginate(:page => params[:page])
  end
  
  def object
    @object ||= Order.find params[:id]
  end
  
  def find_by_month
    @orders = Order.by_month(@date.month).by_year(@date.year).paginate(:page => params[:page])
  end
  
end
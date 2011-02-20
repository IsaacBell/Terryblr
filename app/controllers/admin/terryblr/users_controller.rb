class Admin::Terryblr::UsersController < Terryblr::AdminController

  before_filter :make_admin, :only => [:new, :create] 
  
  show {
    wants.html {
      redirect_to edit_admin_user_path(object)
    }
  }
  
  def admins
    @collection = User.admins.all.paginate(:page => params[:page])
    render :action => "index"
  end
  
  private
  
  def make_admin
    build_object.admin = true
  end
  
  def collection
    @collection ||= User.all.paginate(:page => params[:page])
  end
  
  def object
    @object ||= User.find(params[:id])
  end
  
  def build_object
    @object ||= User.new(params[:user])
  end
  

end

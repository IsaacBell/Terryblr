class Admin::Terryblr::UsersController < Terryblr::AdminController

  before_filter :make_admin, :only => [:new, :create]
  
  show {
    wants.html {
      redirect_to edit_admin_user_path(object)
    }
  }

  def create
    @user = Terryblr::User.new(params[:terryblr_user])
    if @user.save
      redirect_to edit_admin_user_path(@user)
    else
      render :action => :new
    end
  end
  
  def admins
    @collection = Terryblr::User.admins.all.paginate(:page => params[:page])
    render :action => "index"
  end

  private
  
  def make_admin
    build_object.admin = true
  end
  
  def collection
    @collection ||= Terryblr::User.all.paginate(:page => params[:page])
  end
  
  def object
    @object ||= Terryblr::User.find(params[:id])
  end
  
  def build_object
    @object ||= Terryblr::User.new(params[:user])
  end

end

class Admin::Terryblr::UsersController < Terryblr::AdminController

  before_filter :make_admin, :only => [:new, :create]
  
  show {
    wants.html {
      redirect_to edit_admin_user_path(object)
    }
  }

  def create
    @user = end_of_association_chain.new(params[:user])
    @user.admin = true
    if @user.save
      redirect_to edit_admin_user_path(@user)
    else
      render :action => :new
    end
  end
  
  def admins
    @collection = end_of_association_chain.admins.all.paginate(:page => params[:page])
    render :action => "index"
  end

  private
  
  def make_admin
    build_object.admin = true
  end
  
  def collection
    @collection ||= end_of_association_chain.all.paginate(:page => params[:page])
  end
  
  def object
    @object ||= end_of_association_chain.find(params[:id])
  end
  
  def build_object
    @object ||= end_of_association_chain.new(params[:user])
  end
  
  def end_of_association_chain
    Terryblr::User
  end
  
  include Terryblr::Extendable
end

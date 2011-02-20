class Admin::Terryblr::UserSessionsController < Terryblr::AdminController

  # before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  skip_after_filter :set_last_modified
  
  index.wants.html {
    redirect_to admin_path
  }
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])

    if !(result = @user_session.save)
      # Try another
      @user_session = UserSession.new(:password => params[:user_session][:password], :email => params[:user_session][:login])
      result = @user_session.save
    end

    if result
      flash[:notice] = "Login successful!"
      redirect_back_or_default admin_path
    else
      flash[:warning] = "Invalid Login!"
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default admin_path
  end

end

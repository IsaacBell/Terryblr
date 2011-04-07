class Admin::Terryblr::UsersController < Terryblr::AdminController

  def show
    super do |wants|
      wants.html { redirect_to edit_admin_user_path(resource), :flash => flash }
    end
  end

  def create
    super do |success, failure|
      success.html { redirect_to edit_admin_user_path(resource), :notice => t('devise.registrations.signed_up') }
      failure.html { render :action => :new }
    end
  end

  def admins
    @users = end_of_association_chain.admins.all.paginate(:page => params[:page])
    render :action => "index"
  end

  private

  def make_admin
    build_resource.admin = true
  end

  def collection
    @users ||= end_of_association_chain.all.paginate(:page => params[:page])
  end

  def resource_request_name
    :user
  end

  def method_for_build
    :build_admin
  end
  
  def end_of_association_chain
    Terryblr::User
  end
  
  include Terryblr::Extendable
end

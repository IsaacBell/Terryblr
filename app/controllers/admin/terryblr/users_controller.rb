class Admin::Terryblr::UsersController < Terryblr::AdminController

  def show
    show! do |wants|
      wants.html { redirect_to edit_admin_user_path(resource), :flash => flash }
    end
  end

  def create
    create! do |success, failure|
      success.html { redirect_to edit_admin_user_path(resource), :notice => t('devise.registrations.signed_up') }
      failure.html { render :action => :new }
    end
  end

  def admins
    @collection = Terryblr::User.admins.all.paginate(:page => params[:page])
    render :action => "index"
  end

  private

  def make_admin
    build_resource.admin = true
  end

  def collection
    @collection ||= Terryblr::User.all.paginate(:page => params[:page])
  end

  def resource_request_name
    :user
  end

  def method_for_build
    :build_admin
  end

  include Terryblr::Extendable
end

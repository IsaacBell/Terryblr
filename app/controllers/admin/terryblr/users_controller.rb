class Admin::Terryblr::UsersController < Terryblr::AdminController

  before_filter :make_admin, :only => [:new, :create]

  def show
    show! do |wants|
      wants.html { redirect_to edit_admin_user_path(object), :flash => flash }
    end
  end

  def create
    create! do |success, failure|
      success.html { redirect_to edit_admin_user_path(@object), :notice => t('en.devise.registrations.signed_up') }
      failure.html { render :action => :new }
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

  include Terryblr::Extendable
end

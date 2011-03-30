class Terryblr::LikesController < Terryblr::PublicController

  helper "Terryblr::Posts"
  before_filter :require_user, :only => [:create]

  def index
    index! do |success, failure|
      success.html { head :not_found }
      success.json { render :json => collection.to_json }
      success.xml  { render :xml => collection.to_xml }
    end
  end

  def create
    create! do |success, failure|
      success.html { head :ok, :location => post_path(parent_object) }
      success.js
      failure.wants.html { head :error, :message => "You already liked this" }
      failure.wants.js
    end
  end

  private

  def object
    @object ||= parent_object.likes.find(params[:id])
  end

  def build_object
    @object ||= Like.new(:user => current_user, :likeable => parent_object)
  end

  def collection
    @collection ||= parent_object.likes.paginate(:page => params[:page])
  end

  def parent_object
    @parent ||= Terryblr::Post.find_by_slug(params[:post_id]) || Terryblr::Post.find(params[:post_id])
  end

  include Terryblr::Extendable
end
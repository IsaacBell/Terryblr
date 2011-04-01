class Terryblr::CommentsController < Terryblr::PublicController
  helper "Terryblr::Posts"
  before_filter :require_user, :only => [:create, :update]

  def index
    super do |wants|
      wants.html { head :not_found }
      wants.json { render :json => collection.to_json }
      wants.xml { render :xml => collection.to_xml }
    end
  end

  def create
    build_resource.request = request
    super do |success, failure|
      success.html { head :ok, :location => post_path(parent) }
      success.js
      failure.wants.html { head :error, :message => resource.errors.full_messages.to_sentence }
      failure.wants.js
    end
  end

  private

  def resource
    @resource ||= parent.comments.find params[:id]
  end

  def build_resource
    @resource ||= Comment.new params[:comment].update(:user => current_user, :commentable => parent)
  end

  def collection
    @collection ||= parent.comments.approved.paginate :page => params[:page]
  end

  def parent
    @parent ||= Terryblr::Post.find_by_slug(params[:post_id]) || Terryblr::Post.find(params[:post_id])
  end

  include Terryblr::Extendable
end
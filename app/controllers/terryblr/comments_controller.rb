class Terryblr::CommentsController < Terryblr::PublicController

  helper "Terryblr::Posts"
  before_filter :require_user, :only => [:create, :update]

  index {
    wants.html {
      head :not_found
    }
    wants.json {
      render :json => collection.to_json
    }
    wants.xml {
      render :xml => collection.to_xml
    }
  }

  create {
    before {
      build_object.request = request
    }
    wants.html {
      head :ok, :location => post_path(parent_object)
    }
    wants.js
    failure.wants.html {
      head :error, :message => object.errors.full_messages.to_sentence
    }
    failure.wants.js
  }

  private

  def object
    @object ||= parent_object.comments.find(params[:id])
  end

  def build_object
    @object ||= Terryblr::Comment.new(params[:comment].update(:user => current_user, :commentable => parent_object))
  end

  def collection
    @collection ||= parent_object.comments.approved.paginate(:page => params[:page])
  end

  def parent_object
    @parent ||= Terryblr::Post.find_by_slug(params[:post_id]) || Terryblr::Post.find(params[:post_id])
  end

  include Terryblr::Extendable
end
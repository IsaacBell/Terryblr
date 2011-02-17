class Terryblr::LikesController < Terryblr::PublicController

  helper "Terryblr::Posts"
  before_filter :require_user, :only => [:create]

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
    wants.html {
      head :ok, :location => post_path(parent_object)
    }
    wants.js {
      render :update do |page|
        # Update like button
        page.replace parent_object.dom_id('like_label'), like_label(parent_object)
      end
    }
    failure.wants.html {
      head :error, :message => "You already liked this"
    }
    failure.wants.js {
      render :update do |page|
        # Update like button
        page.replace parent_object.dom_id('like_label'), "You already liked this"
      end
    }
  }

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
    @parent ||= Post.find_by_slug(params[:post_id]) || Post.find(params[:post_id])
  end

end
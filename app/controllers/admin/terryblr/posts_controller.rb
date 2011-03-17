class Admin::Terryblr::PostsController < Terryblr::AdminController

  before_filter :set_type, :only => [:edit, :update]
  before_filter :collection, :only => [:index, :filter]

  index {
    before {
      @show_as_dash = true
    }
    wants.js
  }

  def filter
    @show_as_dash = true
    respond_to do |wants|
      wants.html {
        render :action => "index"
      }
    end
  end

  new_action {
    before {
      # Create post!
      object.attributes= object.class.new.attributes.symbolize_keys.update(
        :state => "pending",
        :post_type => params[:type],
        :published_at => nil,
        :twitter_id => nil
      )
      object.save!
      object.slug = ""
    }
    wants.html {
      @type = object.post_type
      render :action => "edit"
    }
  }

  edit {
    @editing = true
  }

  create {
    failure.wants.html {
      render :action => "edit"
    }
  }

  update {
    wants.html {
      if params[:post] and params[:post][:state]=="publish_now"
        flash[:notice] += " <b>Your post is now live!</b>"
      end
      redirect_to admin_posts_path
    }
  }

  show {
    wants.html {
      redirect_to edit_admin_post_path(object)
    }
  }

  destroy {
    wants.html {
      redirect_to admin_posts_path
    }
  }

  private

  def model_name
    'Terryblr::Post'
  end

  def set_type
    @type = object.post_type
  end

  def collection
    scope = case params[:state]
    when "drafted"
      col = :updated_at
      Terryblr::Post.drafted
    else
      col = :published_at
      Terryblr::Post.published
    end

    if params[:month] and params[:year]
      @date = Date.parse("#{params[:year]}-#{params[:month]}-1")
      scope = scope.for_month @date, col
    end

    @posts = @collection ||= scope.order("#{col} desc, created_at desc").paginate(:page => (params[:page] || 1))
    
  end
end

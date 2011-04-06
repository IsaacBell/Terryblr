class Admin::Terryblr::PostsController < Terryblr::AdminController

  before_filter :set_type, :only => [:edit, :update]
  before_filter :collection, :only => [:index, :filter]

  index {
    before {
      @show_as_dash = true
    }
    wants.js {
      render :template => "admin/terryblr/posts/index"
    }
    wants.html {
      render :template => "admin/terryblr/posts/index"
    }
  }

  def filter
    @show_as_dash = true
    respond_to do |wants|
      wants.html {
        render :template => "admin/terryblr/posts/index"
      }
    end
  end

  new_action {
    before {
      # Create post!
      object.attributes= end_of_association_chain.new.attributes.symbolize_keys.update(
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
      render :template => "admin/terryblr/posts/edit"
    }
  }

  edit {
    wants.html {
      render :template => "admin/terryblr/posts/edit"
    }
  }

  create {
    failure.wants.html {
      render :template => "admin/terryblr/posts/edit"
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

  def show
    redirect_to edit_admin_post_path(object)
  end

  destroy {
    wants.html {
      redirect_to admin_posts_path
    }
  }

  private

  def set_type
    @type = object.post_type
  end

  def collection
    col_scope = end_of_association_chain.scoped
    col_scope = case params[:state]
    when "drafted"
      col = :updated_at
      col_scope.drafted
    else
      col = :published_at
      col_scope.published
    end

    if params[:month] and params[:year]
      @date = Date.parse("#{params[:year]}-#{params[:month]}-1")
      col_scope = col_scope.for_month @date, col
    end
    
    col_scope = col_scope.order("#{col} desc, created_at desc")

    # Show all if drafts
    col_scope = if params[:state]=='drafted'
      col_scope.all
    else
      col_scope.paginate(:page => (params[:page] || 1))
    end

    @posts = @collection ||= col_scope
    
  end

  include Terryblr::Extendable
end

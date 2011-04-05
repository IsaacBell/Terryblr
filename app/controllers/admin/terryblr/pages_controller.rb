class Admin::Terryblr::PagesController < Terryblr::AdminController

  index {
    before {
      @list_cols = %w(page state)
      @action_cols = %w(add_child)
    }
    wants.html {}
    wants.js
  }

  new_action {
    before {
      # Create post!
      object.save!
      object.state = :published
      object.parent_id = params[:parent_id].to_i if params[:parent_id]
    }
    wants.html {
      render :action => "edit"
    }
  }

  show {
    wants.html {
      redirect_to admin_pages_path
    }
  }
  
  private

  def collection
    order = "created_at desc"
    @collection = @posts ||= if params[:parent_id]
      end_of_association_chain.by_state(params[:state] || 'published').all(:conditions => {:parent_id => params[:parent_id]}, :order => order)
    else
      end_of_association_chain.roots.by_state(params[:state] || 'published').all(:order => order)
    end
  end
  
  include Terryblr::Extendable

end

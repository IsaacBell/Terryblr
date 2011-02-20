class Admin::Terryblr::PagesController < Terryblr::AdminController

  index {
    before {
      @list_cols = %w(page state)
      @action_cols = %w(add_child)
    }
    wants.html {}
    wants.js {
      dom_id = "tablerow_#{params[:parent_id]}" if params[:parent_id]
      render :update do |page|
        # Insert rows
        if dom_id
          page.insert_html :after, dom_id, 
            :partial => 'admin/common/list_table_row', 
            :collection => @collection, 
            :as => :record, 
            :locals => { 
              :list_cols => @list_cols, 
              :cols_hash => Page.columns_hash, 
              :ignore_cols => [], 
              :action_cols => @action_cols, 
              :record_name => :page
            }
        end
        # Mark expand button as expanded
        page << "$('#tablerow_1 span.collapsed').addClass('expanded').removeClass('collapsed')"
      end
    }
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
      redirect_to edit_admin_page_path(object)
    }
  }
  
  private
  
  def collection
    order = "created_at desc"
    @collection = @posts ||= if params[:parent_id]
      Page.by_state(params[:state] || 'published').all(:conditions => {:parent_id => params[:parent_id]}, :order => order)
    else
      Page.roots.by_state(params[:state] || 'published').all(:order => order)
    end
  end
  
end

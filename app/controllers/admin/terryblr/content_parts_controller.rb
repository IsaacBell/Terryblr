class Admin::Terryblr::ContentPartsController < Terryblr::AdminController
  helper 'admin/terryblr/dropbox'
  helper 'admin/terryblr/posts'

  def new
    if Terryblr::ContentPart.content_types.include?(params[:content_type])
      resource.content_type = params[:content_type]
    end
    super do |wants|
      wants.js
    end
  end

  def reorder
    if params[:parts_list].is_a?(Array)
      i = 0
      params[:parts_list].each do |id|
        Terryblr::ContentPart.update_all({:display_order => (i+=1)}, {:id => id})
      end
      render :nothing => true, :status => :ok
    else
      render :nothing => true, :status => :error
    end
  end
  
  def destroy
    super do |wants|
      wants.html { head :ok }
      wants.xml  { head :ok }
      wants.json { head :ok }
      wants.js
    end
  end
  

  private

  def collection
    @collection ||= post.parts.all
  end

  include Terryblr::Extendable
end
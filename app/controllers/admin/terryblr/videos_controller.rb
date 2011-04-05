class Admin::Terryblr::VideosController < Terryblr::AdminController

  helper "admin/terryblr/posts"

  def create
    object = if params.key?(:Filedata)
      Terryblr::Video.new(:upload => params[:Filedata], :post => post)
    elsif params.key?(:video_url)
      Terryblr::Video.new(:url => params[:video_url], :post => post)
    end
    
    if object.save
      respond_to do |wants|
        wants.js
        wants.html { render :status => :ok }
      end
    else
      logger.debug { "video errors: #{object.errors.full_messages.to_sentence}\n#{object.inspect}" }
      render :text => object.errors.full_messages.to_sentence
    end
  end
  
  def reorder
    if params[:videos_list].is_a?(Array)
      i = 0
      params[:videos_list].each do |id|
        Terryblr::Video.update_all({:display_order => (i+=1)}, {:id => id})
      end
      render :nothing => true, :status => :ok
    else
      render :nothing => true, :status => :error
    end
  end
  
  destroy {
    wants.js
    failure.wants.js
  }
  
  private
  
  def post
    @post ||= current_site.posts.find_by_slug(params[:post_id]) || current_site.posts.find_by_id(params[:post_id]) || current_site.posts.new
  end
  
  def object
    @object ||= end_of_association_chain.find(params[:id])
  end
  
  include Terryblr::Extendable
end

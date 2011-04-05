class Admin::Terryblr::VideosController < Terryblr::AdminController

  helper "admin/terryblr/posts"

  def create
    resource = if params.key?(:Filedata)
      end_of_association_chain.new(:upload => params[:Filedata], :post => post)
    elsif params.key?(:video_url)
      end_of_association_chain.new(:url => params[:video_url], :post => post)
    end
    
    if resource.save
      respond_to do |wants|
        wants.js
        wants.html { render :status => :ok }
      end
    else
      logger.debug { "video errors: #{resource.errors.full_messages.to_sentence}\n#{resource.inspect}" }
      render :text => resource.errors.full_messages.to_sentence
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

  private

  def post
    @post ||= Terryblr::Post.find_by_slug(params[:post_id]) || 
              Terryblr::Post.find_by_id(params[:post_id]) || 
              Terryblr::Post.new
  end

  def resource
    @video ||= end_of_association_chain.find(params[:id])
  end

  include Terryblr::Extendable
end
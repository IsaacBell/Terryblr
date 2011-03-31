class Admin::Terryblr::PhotosController < Terryblr::AdminController

  def create
    @photo = end_of_association_chain.new(:image => params[:Filedata])

    # Features belong to the photo and not the otherway
    if photoable.is_a?(Terryblr::Feature)
      feature = photoable

      # Delete any others photos unless they belong to posts
      feature.photo.destroy if feature.photo and feature.photo.photoable.nil?

      @photo.features << feature
    else
      @photo.photoable = photoable
    end

    respond_to do |wants|
      if @photo.save
        wants.js
        wants.html { 
          render :template => "admin/terryblr/photos/create.js.haml", :layout => false, :status => :ok 
        }
      else
        flash[:error] = "Unable to save image: #{@photo.errors.full_messages.to_sentence}"
        logger.error { "Photo errors: #{@photo.errors.full_messages.to_sentence}" }
        wants.js
        wants.html {
          render :text => @photo.errors.full_messages.to_sentence
        }
      end
    end
  end

  def reorder
    if params[:photos_list].is_a?(Array)
      i = 0
      params[:photos_list].each do |id|
        Terryblr::Photo.update_all({:display_order => (i+=1)}, {:id => id})
      end
      render :nothing => true, :status => :ok
    else
      render :nothing => true, :status => :error
    end
  end

  private

  def photoable
    @photoable ||= if params[:post_id]
      Terryblr::Post.find_by_slug(params[:post_id]) || Terryblr::Post.find_by_id(params[:post_id].to_i) || Terryblr::Post.new
    elsif params[:product_id]
      Terryblr::Product.find_by_slug(params[:product_id]) || Terryblr::Product.find_by_id(params[:product_id].to_i) || Terryblr::Product.new
    elsif params[:page_id]
      Terryblr::Page.find_by_slug(params[:page_id]) || Terryblr::Page.find_by_id(params[:page_id].to_i) || Terryblr::Page.new
    elsif params[:feature_id]
      Terryblr::Feature.find_by_id(params[:feature_id].to_i) || Terryblr::Feature.new
    end
  end

  include Terryblr::Extendable
end
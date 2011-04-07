class Admin::Terryblr::PhotosController < Terryblr::AdminController

  def create
    @photo = end_of_association_chain.new(:image => params[:Filedata])

    # Features belong to the photo and not the otherway
    if photoable && photoable.is_a?(Terryblr::Feature)
      feature = photoable

      # Delete any others photos unless they belong to posts
      feature.photo.destroy if feature.photo and feature.photo.photoable.nil?

      @photo.features << feature
    else
      @photo.photoable = photoable
    end

    super do |success, failure|
      success.json { render @photo.to_json }
      success.html { render :template => "admin/terryblr/photos/create.js.haml", :layout => false, :status => :ok }
      failure.json { render @photo.errors.to_json }
      failure.html { render :text => @photo.errors.full_messages.to_sentence }
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
      current_site.posts.find_by_slug(params[:post_id]) || current_site.posts.find_by_id(params[:post_id].to_i) || current_site.posts.new
    elsif params[:product_id]
      Terryblr::Product.find_by_slug(params[:product_id]) || Terryblr::Product.find_by_id(params[:product_id].to_i) || Terryblr::Product.new
    elsif params[:page_id]
      current_site.pages.find_by_slug(params[:page_id]) || current_site.pages.find_by_id(params[:page_id].to_i) || current_site.pages.new
    elsif params[:feature_id]
      current_site.features.find_by_id(params[:feature_id].to_i) || current_site.features.new
    end
  end

  include Terryblr::Extendable
end

class Admin::Terryblr::PhotosController < Terryblr::AdminController

  def create
    @object = Photo.new(:image => params[:Filedata])

    # Features belong to the photo and not the otherway
    if photoable.is_a?(Feature)
      feature = photoable

      # Delete any others photos unless they belong to posts
      feature.photo.destroy if feature.photo and feature.photo.photoable.nil?

      @object.features << feature
    else
      @object.photoable = photoable
    end

    respond_to do |wants|
      if @object.save
        wants.js {
          if photoable.is_a?(Page) or (photoable.is_a?(Post) and photoable.post_type.post?)
            render :inline => "<%= image_tag(@object.image.url(:medium)) %>"
          else
            render :update do |page|
              if params[:feature_id]
                list_id = "feature_photo"
                page.replace_html "#{list_id}_ul", photo_for_assoc(@object, @photoable, list_id)
              else
                list_id = "photos_list"
                page.insert_html :bottom, "#{list_id}_ul", photo_for_assoc(@object, @object.photoable, list_id)
                page << "$('##{list_id}').sortable('refresh')"
              end
            end
          end
        }
        wants.html { render :status => :ok }
      else
        logger.error { "Photo errors: #{@object.errors.full_messages.to_sentence}" }
        wants.js {
          render :update do |page|
            flash[:error] = "Unable to save image: #{@object.errors.full_messages.to_sentence}"
            page.replace_html "flash_messages", flash_messages
          end
        }
        wants.html {
          render :text => @object.errors.full_messages.to_sentence
        }
      end
    end
  end

  def reorder
    if params[:photos_list].is_a?(Array)
      i = 0
      params[:photos_list].each do |id|
        Photo.update_all({:display_order => (i+=1)}, {:id => id})
      end
      render :nothing => true, :status => :ok
    else
      render :nothing => true, :status => :error
    end
  end

  destroy {
    wants.js {
      render :update do |page|
        page.visual_effect :fade, object.dom_id('photos_list')
        page.delay(2) do
          page.remove object.dom_id('photos_list')
        end
      end
    }
    failure.wants.js {
      render :update do |page|
        page.replace "flash", flash_messages
        page.visual_effect :appear, "flash"
      end
    }
  }

  private

  def photoable
    @photoable ||= if params[:post_id]
      Post.find_by_slug(params[:post_id]) || Post.find_by_id(params[:post_id].to_i) || Post.new
    elsif params[:product_id]
      Product.find_by_slug(params[:product_id]) || Product.find_by_id(params[:product_id].to_i) || Product.new
    elsif params[:page_id]
      Page.find_by_slug(params[:page_id]) || Page.find_by_id(params[:page_id].to_i) || Page.new
    elsif params[:feature_id]
      Feature.find_by_id(params[:feature_id].to_i) || Feature.new
    end
  end

  def object
    @object ||= end_of_association_chain.find_by_id(params[:id])
  end

end
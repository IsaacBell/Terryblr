class Admin::Terryblr::PhotosController < Terryblr::AdminController

  helper 'admin/terryblr/dropbox'
  include Admin::Terryblr::DropboxHelper
  skip_before_filter :verify_authenticity_token, :only => [:create]

  respond_to :html, :js

  def create
    if params[:dropbox_path]
      dropbox_session.mode = :dropbox
      puts "Downloading from dropbox..."
      start = Time.now
      data = StringIO.new dropbox_session.download(params[:dropbox_path])
      puts "Downloaded in #{Time.now - start}..."
      filename = File.basename params[:dropbox_path]
      puts "Filename: #{filename}"
    else
      # Flash photo upload
      # From gist: https://gist.github.com/26082d2b56b00bd54dad
      data = request.body
      filename = params[:qqfile]
    end
    data.class.send(:define_method, "original_filename") do
      filename
    end

    @photo = end_of_association_chain.new(:image => data, :image_file_name => filename)

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
      success.js   { render :template => "admin/terryblr/photos/create.js.haml", :layout => false, :status => :ok }
      success.html { render :template => "admin/terryblr/photos/create.js.haml", :layout => false, :status => :ok }
      failure.json { render @photo.errors.to_json }
      failure.js   { render :text => @photo.errors.full_messages.to_sentence }
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
    @photoable ||= if params[:content_part_id] || params[:part_id]
      Terryblr::ContentPart.find_by_id((params[:content_part_id] || params[:part_id]).to_i) || 
      Terryblr::ContentPart.new(:content_type => 'photos', :photos => [resource])
    elsif params[:feature_id]
      current_site.features.find_by_id(params[:feature_id].to_i) || 
      current_site.features.new
    end
  end

  include Terryblr::Extendable
end

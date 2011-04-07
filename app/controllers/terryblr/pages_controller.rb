class Terryblr::PagesController < Terryblr::PublicController

  show {
    before {
      @page_title = object.title
    }
    failure.wants.html {
      raise ActiveRecord::RecordNotFound
    }
  }
  
  def preview
    @object = end_of_association_chain.new(params[:page])
    @object.id ||= 0
    @object.published_at = 1.minute.ago
    @object.slug = 'preview' unless @object.slug?
    @body_classes = "page-show" # So that CSS will think it's the details page
    respond_to do |wants|
      wants.html {
        render :template => "terryblr/pages/show"
      }
    end
  end

  private

  def object
    @page = @object ||= end_of_association_chain.find_by_slug(params[:page_slug]) || 
                        end_of_association_chain.find_by_slug(params[:id]) || 
                        (raise ActiveRecord::RecordNotFound)
  end

  include Terryblr::Extendable
end

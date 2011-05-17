class Terryblr::PagesController < Terryblr::PublicController

  def show
    track_resource_analytics
    @page_title = resource.title
    super
  end
  
  def preview
    @page = end_of_association_chain.new(params[:page])
    @page.id ||= 0
    @page.published_at = 1.minute.ago
    @page.slug = 'preview' unless @page.slug?
    @body_classes = "page-show" # So that CSS will think it's the details page
    respond_to do |wants|
      wants.html {
        render :template => "terryblr/pages/show"
      }
    end
  end
  
  private

  def resource
    @page ||= end_of_association_chain.find_by_slug(params[:page_slug]) || 
              end_of_association_chain.find_by_slug(params[:id])
  end

  include Terryblr::Extendable
end

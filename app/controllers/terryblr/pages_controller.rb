class Terryblr::PagesController < Terryblr::PublicController

  def show
    @page_title = resource.title
    super
  end

  private

  def resource
    @page ||= end_of_association_chain.find_by_slug(params[:page_slug]) || 
              end_of_association_chain.find_by_slug(params[:id])
  end

  include Terryblr::Extendable
end
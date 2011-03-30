class Terryblr::PagesController < Terryblr::PublicController

  def show
    @page_title = object.title
    super
  end

  private

  def object
    @page = @object ||= end_of_association_chain.find_by_slug(params[:page_slug]) || 
                        end_of_association_chain.find_by_slug(params[:id]) || 
                        (raise ActiveRecord::RecordNotFound)
  end

  def end_of_association_chain
    Terryblr::Page
  end

  include Terryblr::Extendable
end
class Terryblr::PagesController < Terryblr::PublicController

  def show
    @page_title = object.title
    show! do |success, failure|
      failure.wants.html { raise ActiveRecord::RecordNotFound }
    end
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
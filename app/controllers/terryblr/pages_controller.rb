class Terryblr::PagesController < Terryblr::PublicController

  show {
    before {
      @page_title = object.title
    }
    failure.wants.html {
      raise ActiveRecord::RecordNotFound
    }
  }

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

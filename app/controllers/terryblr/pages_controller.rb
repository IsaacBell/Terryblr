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
    @page = @object ||= page_chain.find_by_slug(params[:page_slug]) || 
                        page_chain.find_by_slug(params[:id]) || 
                        (raise ActiveRecord::RecordNotFound)
  end
  
  def page_chain
    Terryblr::Page
  end
  

end

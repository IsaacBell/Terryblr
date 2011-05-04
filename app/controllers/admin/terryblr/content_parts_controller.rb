class Admin::Terryblr::ContentPartsController < Terryblr::AdminController

  def reorder
    if params[:parts_list].is_a?(Array)
      i = 0
      params[:parts_list].each do |id|
        Terryblr::ContentPart.update_all({:display_order => (i+=1)}, {:id => id})
      end
      render :nothing => true, :status => :ok
    else
      render :nothing => true, :status => :error
    end
  end

  private

  def collection
    @collection ||= post.parts.all
  end

  include Terryblr::Extendable
end
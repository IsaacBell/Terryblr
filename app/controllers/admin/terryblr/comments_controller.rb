class Admin::Terryblr::CommentsController < Terryblr::AdminController

  private

  def collection
    scope = end_of_association_chain
    
    unless params[:search].blank?
      @query = params[:search].strip
      scope = scope.comment_like(@query)
    end
    
    unless params[:post_id].blank?
      scope = scope.commentable_type('Terryblr::Post').commentable_id(params[:post_id])
    end
    
    # TODO: check if acts_as_commentable's comments_ordered_by_submitted would fit here
    @collection ||= scope.all(:order => "created_at desc").paginate(:page => params[:page])
  end

  include Terryblr::Extendable
end
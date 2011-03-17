module Admin::Terryblr::CommentsHelper
  
  def author_column(comment)
    comment.user ? comment.user.full_name : "Anonymous"
  end
  
  
  include Terryblr::Extendable
end

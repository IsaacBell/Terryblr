module Admin::Terryblr::CommentsHelper
  
  def author_field(comment)
    comment.user ? comment.user.full_name : "Anonymous"
  end
  
  
end

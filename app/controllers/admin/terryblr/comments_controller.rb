require 'disqussion'
class Admin::Terryblr::CommentsController < Terryblr::AdminController

  def index
    super
  end
  
  def update_many
    posts = Disqussion::Posts.new
    case params[:comment_action]
    when 'approve'
      posts.approve params[:comment_ids] if params[:comment_ids]
    when 'mark-spam'
      posts.spam params[:comment_ids] if params[:comment_ids]
    end if params[:comment_action]
    redirect_to admin_comments_path
  end
  
  def delete_many
    Disqussion::Posts.new.remove params[:comment_ids] if params[:comment_ids]
    redirect_to admin_comments_path
  end
  
  private
  
  # Query options are passed this way:
  # from:username
  # email:joe@bar.com
  # ip:127.0.0.1
  # thread:29372
  def extract_options
    options = {}
    options[:query] = params[:query] if params.has_key?(:query) && %w(from email ip thread).include?(params[:query].split(':').first)
    options[:include] = params[:filter] if params.has_key? :filter
    options
  end
  
  def collection
    @collection ||= begin
      posts = Disqussion::Forums.new.listPosts(Settings.disqus.forum, extract_options).response
      unless Rails.env.test?
        f = Fiber.current
        # Launch up to 10 requests in parallel
        EM::Iterator.new(posts, 10).map(proc{ |comment, iter|
          Fiber.new {
            comment.thread = Disqussion::Threads.new.details(comment.thread).response
            iter.return(comment.thread)
          }.resume
        }, proc{ |responses|
          f.resume
        })
        Fiber.yield
      end
      posts
    end
  end

  include Terryblr::Extendable
end
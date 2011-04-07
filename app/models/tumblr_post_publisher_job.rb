TumblrPostPublisherJob = Struct.new(:post_id)

class TumblrPostPublisherJob

  require 'tumblr'

  include Rails.application.routes.url_helpers
  default_url_options[:host] = Settings.domain

  def perform

    # Find objects
    post = Terryblr::Post.find(post_id)

    # Abort if already posted
    return if post.tumblr_id?

    # Common part
    tumblr = {
      :slug => post.slug
    }
    
    add_link_for_more = false
    
    case post.post_type
    when "post"
      tumblr.merge!({
        :type       => "regular",
        :title      => post.title,
        :body       => post.body
      })
    when "video"
      tumblr.merge!({
        :type     => "video",
        :embed    => post.videos.first.url,
        :caption  => post.videos.first.caption
      })
      add_link_for_more = (post.videos.count > 1)
    when "photos"
      tumblr.merge!({
        :type     => "photo",
        :source   => post.photos.first.image.url,
        :caption  => post.photos.first.caption
      })
      add_link_for_more = (post.photos.count > 1)
    end
    
    link = post_url(post, :slug => post.slug)
    
    tumblr[:caption] += "<br />View more <a href='#{link}'>here</a>" if add_link_for_more
    
    # Authentication
    user = Tumblr::User.new(Settings.tumblr.email, Settings.tumblr.pass, false)
    
    tumblr_id = Tumblr::Post.create(user, tumblr)
    
    # Tumblr it!
    post.update_tumblr_id(tumblr_id)
  end

  include Terryblr::Extendable
end
require 'uri'
require 'yaml'
require 'mini_fb'

# 
# Delayed::Job.enqueue(FbPostPublisherJob.new(post.id, url))
# 
FbPostPublisherJob = Struct.new(:post_id)
class FbPostPublisherJob
  
  include ActionController::UrlWriter
  default_url_options[:host] = Settings.domain
  
  def perform
    post = Post.find post_id
    
    # Abort if already posted
    return if post.facebook_id?

    url  = post_url(:id => post.to_param, :slug => post.slug.to_s)
    msg  = !post.social_msg.blank? ? post.social_msg : post.title.truncate(140)
    body = post.body.gsub(%r{</?[^>]+?>}, '').gsub(/&nbsp;/,' ').truncate(420)
    default_img_path = "#{root_url}images/fb_share.png"
    img_url = if post.post_type.video? && !post.videos.empty?
      post.videos.first.thumb_url rescue default_img_path
    else
      uri = URI.parse(url)
      !post.photos.empty? ? "#{uri.scheme}://#{uri.host}#{post.photos.first.image.url(:thumb)}" : default_img_path
    end

    resp = facebook.post("/me/feed", {
      :message => msg,
      :name => "#{Settings.app_name} - #{post.title.truncate(420)}",
      :from => Settings.facebook.page_id, # Post as the page
      :link => url,
      :source => (post.post_type.video? && !post.videos.empty?) ? post.videos.first.url : img_url,
      :caption => body, 
      :description => Settings.app_name,
      :picture => img_url,
      :likes => true
    })

    # needs checking vs. returned facebook json object
    if resp.keys.include?('id')
      post.update_facebook_id(resp["id"])
    end

  end

  protected
  
  # Return a facebook client object
  def facebook
    MiniFB.disable_logging
    @facebook ||= MiniFB::OAuthSession.new(Settings.facebook.page_token)
  end

end


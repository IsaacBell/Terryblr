require 'yaml'
require 'twitter'
# require 'bitly'

# 
# Delayed::Job.enqueue(TwCommentPublisherJob.new(post.id, url))
# 
TwPostPublisherJob = Struct.new(:post_id)
class TwPostPublisherJob

  include ActionController::UrlWriter
  default_url_options[:host] = Settings.domain

  def perform

    # Find objects
    post = Post.find(post_id)

    # Abort if already posted
    return if post.twitter_id?

    # Auth user 
    oauth = Twitter::OAuth.new(Settings.twitter.consumer_key, Settings.twitter.consumer_secret)
    oauth.authorize_from_access(Settings.twitter.app_user_token, Settings.twitter.app_user_secret)

    # Shorten URL - take this out for now as not clear enough
    bitly = Bitly.new(Settings.bitly.login, Settings.bitly.key)
    url = post_url(:id => post.to_param, :slug => post.slug.to_s)
    short_url = bitly.shorten(url.to_s).short_url rescue url
    
    # Build message
    body = !post.social_msg.blank? ? post.social_msg : post.title.truncate(160 - 1 - short_url.size)
    msg = "New Post! #{body} #{short_url}"

    # Tweet!
    client = Twitter::Base.new(oauth)
    tweet = client.update(msg)
    post.update_twitter_id(tweet.id)
  end    
end

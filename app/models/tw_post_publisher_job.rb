# Class to aid in the publishing of posts to Twitter. 
# This is typically used with Delayed Job in a background process
# Eg:
#  Delayed::Job.enqueue(TwCommentPublisherJob.new(post.id, url))
# 
# It requires that there is a 'twitter' section in your settings.yml config file
# 
TwPostPublisherJob = Struct.new(:post_id)
class TwPostPublisherJob

  return false unless Settings.has_key?('twitter')

  require 'yaml'
  require 'twitter' unless defined? Twitter

  include Rails.application.routes.url_helpers
  default_url_options[:host] = Settings.domain

  # Executes the job. This authorizes the client with Twitter using settings.yml configuration
  # It will update the post object with the posts twitter_id on success
  # @return [Int] the twitter id of the newly created post
  def perform

    # Find objects
    post = Terryblr::Post.find(post_id)

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

  include Terryblr::Extendable
end
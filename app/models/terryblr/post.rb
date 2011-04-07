class Terryblr::Post < Terryblr::Base

  include Terryblr::Base::Taggable
  include Terryblr::Base::AasmStates
  include Terryblr::Base::Validation

  #
  # Constants
  #
  @@post_types = %w(post photos video)
  @@display_types = %w(photos gallery)

  #
  # Associatons
  #
  has_many :features, :class_name => "Terryblr::Feature"
  has_many :photos, :as => :photoable, :order => "display_order", :class_name => "Terryblr::Photo", :dependent => :destroy
  has_many :videos, :order => "display_order", :dependent => :destroy, :class_name => "Terryblr::Video"
  belongs_to :site, :class_name => "Terryblr::Site"
  belongs_to :tw_delayed_job, :class_name => "::Delayed::Job"
  belongs_to :fb_delayed_job, :class_name => "::Delayed::Job"
  belongs_to :tumblr_delayed_job, :class_name => "::Delayed::Job"
  # has_many :likes, :as => :likeable, :class_name => "Terryblr::Like"
  # has_many :comments, :as => :commentable, :class_name => "Terryblr::Comment"
  # has_many :votes, :as => :votable, :class_name => "Terryblr::Vote"

  #
  # Behaviours
  #

  attr_accessor :url, :tw_me, :fb_me, :tumblr_me

  #XXX acts_as_commentable
  accepts_nested_attributes_for :photos, :allow_destroy => true
  accepts_nested_attributes_for :videos, :allow_destroy => true, :reject_if => Proc.new{|v| v["url"].blank? }

  #
  # Validations
  #
  validates_presence_of :post_type, :unless => :pending? 
  validates_presence_of :slug, :unless => :pending?, :message => "can't be blank. Did you set a title?"
  validates_length_of :social_msg, :within => 0..140, :if => :social_msg?
  validates_inclusion_of :post_type, :in => @@post_types
  validates_inclusion_of :display_type, :in => @@display_types
  validate :state_status

  def state_status
    # Validations depending on post-type
    unless pending?
      case state.to_sym
      when :post
        errors.add(:body, "cannot be empty") unless body?
      when :gallery
        errors.add(:photos, "cannot be empty") if photos.empty?
      when :video
        errors.add(:videos, "cannot be empty") if videos.empty?
      end
    end
  end

  #
  # Scopes
  #
  default_scope order("posts.published_at desc, posts.id desc")

  scope :for_month, lambda { |date, col|
    col ||= :published_at
    where("#{col} >= ? AND #{col} <= ?", date.to_time.beginning_of_month, date.to_time.end_of_month)
  }

  scope :by_month, lambda { |*args|
    # Needs to be sep variable or AR will cache the first time and it'll never change
    now = Time.zone.now
    select("distinct(EXTRACT(DAY from posts.published_at)), posts.*").
    where("EXTRACT(MONTH from posts.published_at) = ? and EXTRACT(YEAR from posts.published_at) = ? and posts.published_at <= ?",  args.flatten[0].to_i, now.year, now).
    order("posts.published_at asc")
  }

  scope :by_year, lambda { |year|
    # Needs to be sep variable or AR will cache the first time and it'll never change
    where("EXTRACT(YEAR from posts.published_at) = ? and posts.published_at <= ?",  year.to_i, Time.zone.now)
  }

  scope :popular_photos, lambda {
    now = Time.zone.now
    joins("INNER JOIN photos ON photos.photoable_type = 'Terryblr::Post' AND photos.photoable_id = posts.id").
    select("posts.*, ((comments_count*2)+likes_count) as final_count").
    where("posts.state = 'published' AND posts.published_at < ? AND posts.published_at < ?", now-1.week, now).
    order("final_count desc, published_at desc").
    group("posts.id").
    limit(6)
  }

  @@post_types.each do |type|
    scope type.pluralize, where(:post_type => type.to_s)
  end

  #
  # Callbacks
  #
  after_initialize :set_display_type
  after_initialize :setup_social_network
  after_initialize :set_diary

  def set_display_type
    self.display_type ||= @@display_types.first
  end

  def setup_social_network
    # Setup social network callback flags
    begin
      self.tw_me      ||= (pending? or tw_delayed_job_id?) unless twitter_id?
      self.fb_me      ||= (pending? or fb_delayed_job_id?) unless facebook_id?
      self.tumblr_me  ||= (pending? or tumblr_delayed_job_id?) unless tumblr_id?
    rescue
    end
  end

  def set_diary
    # Set diary as default location
    if pending? or new_record? and respond_to?(:location_list) and location_list.empty?
      location_list << Settings.tags.posts.location.first
    end
  end

  before_save :fix_tiny_mce
  before_save :push_publication
  before_save :push_to_social

  def push_publication
    # If have just been saved as published then do do_publish to post to twitter/fb etc
    do_publish if (state_changed? and published?) or (!state_changed? and published_at_changed?)
  end

  def push_to_social
    # Terryblr::Post to social networks
    social_cross_posts if published? and (tw_me or fb_me or tumblr_me)
  end

  #
  # Class Methods
  #
  class << self

    def next(post)
      with_exclusive_scope { 
        # Due to problems with the default_scope ordering the 'live' scope must come AFTER the order scope
        where("published_at > ? and id != ?", post.published_at, post.id).order("published_at asc, id asc").live.first
      }
    end

    def previous(post)
      with_exclusive_scope { 
        # Due to problems with the default_scope ordering the 'live' scope must come AFTER the order scope
        where("published_at < ? and id != ?", post.published_at, post.id).order("published_at desc, id desc").live.first
      }
    end

    def next_month(month = Date.today.month)
      p = self.live.first(:conditions => ["EXTRACT(MONTH from published_at) > ?", month.to_i], :order => "published_at asc, id desc")
      p ? p.published_at.month : nil
    end

    def previous_month(month = Date.today.month)
      p = self.live.first(:conditions => ["EXTRACT(MONTH from published_at) < ?", month.to_i], :order => "published_at desc, id desc")
      p ? p.published_at.month : nil
    end

    def post_types
      @@post_types
    end

    def display_types
      @@display_types
    end
    
    def base_class
      self
    end
  end

  #
  # Instance Methods
  #
  def to_param
    # Used for urls like /posts/:id/:slug
    id.to_s
  end

  def next
    @_next ||= self.class.next(self)
  end

  def previous
    @_previous ||= self.class.previous(self)
  end

  def post_type
    @_post_type ||= ActiveSupport::StringInquirer.new(read_attribute(:post_type)) unless read_attribute(:post_type).blank?
  end

  def display_type
    @_display_type ||= ActiveSupport::StringInquirer.new(read_attribute(:display_type)) unless read_attribute(:display_type).blank?
  end

  def related_posts
    # Don't recalc twice
    return @related_posts unless @related_posts.nil?

    max = 6
    @related_posts  = []
    @related_posts += Terryblr::Post.live.tagged_with(tag_list, :match_all => :true).all(:conditions => ["posts.id not in (?)", [id]], :limit => max) rescue []
    @related_posts += Terryblr::Post.live.tagged_with(tag_list, :any       => :true).all(:conditions => ["posts.id not in (?)", @related_posts.map(&:id)+[id]], :limit => max - @related_posts.size) if @related_posts.size < max rescue []
    @related_posts.uniq!
    @related_posts += Terryblr::Post.live.all(:conditions => ["posts.id not in (?)", @related_posts.map(&:id)+[id]], :limit => max - @related_posts.size) if @related_posts.size < max rescue []
    @related_posts
  end

  def update_twitter_id(twitter_id)
    self.twitter_id = twitter_id
    save
  end

  def update_facebook_id(facebook_id)
    self.facebook_id = facebook_id
    save
  end

  def update_tumblr_id(tumblr_id)
    self.tumblr_id = tumblr_id
    save
  end

  def post_types
    self.class.post_types
  end

  def slug=(value)
    # Do not let id based slugs through
    write_attribute(:slug, value.to_s.match(/^\d+$/) ? nil : value)
  end

  # Make social posting flags understand booleans and form submitted num booleans
  def tw_me=(value)
    @tw_me = (value.is_a?(TrueClass) || value.is_a?(FalseClass)) ? value : !value.to_i.zero?
  end

  def fb_me=(value)
    @fb_me = (value.is_a?(TrueClass) || value.is_a?(FalseClass)) ? value : !value.to_i.zero?
  end

  def tumblr_me=(value)
    @tumblr_me = (value.is_a?(TrueClass) || value.is_a?(FalseClass)) ? value : !value.to_i.zero?
  end
  
  private

  def do_publish(msg = nil)
    now = Time.zone.now

    unless published_at?
      self.published_at = now
      save
    end
  end

  def social_cross_posts
    %w(tw fb).each do |prefix|
      next unless self.send("#{prefix}_me")

      assoc = "#{prefix}_delayed_job"

      # No Delayed Job id set or is failed? Then create one.
      if !self.send("#{assoc}_id?") or (self.send(assoc) and self.send(assoc).failed_at?)
        # Create new instance of class that will post to the soc network
        job = "#{prefix.capitalize}PostPublisherJob".constantize.new(self.id)
        dj = ::Delayed::Job.enqueue :payload_object => job, :priority =>  0, :run_at => self.published_at
        self.send("#{assoc}=", dj)

        # If already got a delayed job awaiting, then update the exec date
      elsif self.send(assoc) and self.send(assoc).run_at != self.published_at
        self.send(assoc).update_attribute(:run_at, self.published_at)
      end
    end
  end

  include Terryblr::Extendable
end
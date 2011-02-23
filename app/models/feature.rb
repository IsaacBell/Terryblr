class Feature < Terryblr::Base

  #
  # Behaviours
  #
  include Terryblr::Base::Taggable
  include Terryblr::Base::AasmStates
  include Terryblr::Base::Validation

  #
  # Associatons
  #
  belongs_to :photo
  belongs_to :post

  #
  # Constants
  #
  attr_accessor :photo_url
  accepts_nested_attributes_for :photo, :allow_destroy => true

  #
  # Validations
  #
  include ActiveRecord::Validations
  validates_presence_of :photo, :display_order, :if => Proc.new{|f| !f.pending? && !f.post_id? }
  validates_numericality_of :display_order
  validates :url, :presence => true, :url => true, :if => :url?

  #
  # Scopes
  #
  default_scope order("features.display_order asc, features.id desc")

  #
  # Callbacks
  #
  after_initialize :set_tag_list

  def set_tag_list
    self.tag_list = [Settings.tags.posts.features.first] if self.tag_list.empty? rescue []
  end

  #
  # Class Methods
  #
  class << self
  end

  #
  # Instance Methods
  #

  def photo
    if post_id?
      post.photos.first
    elsif photo_id?
      @photo ||= Photo.find(photo_id)
    end
  end

  private

end

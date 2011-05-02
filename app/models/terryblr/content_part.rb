class Terryblr::ContentPart < Terryblr::Base

  include Terryblr::Base::Validation

  #
  # Constants
  #
  @@content_types = %w(text photos video)
  @@display_types = %w(photos gallery)

  #
  # Associatons
  #
  belongs_to :contantable, :polymorphic => true, :touch => true
  has_many :photos, :as => :photoable, :order => "display_order", :class_name => "Terryblr::Photo", :dependent => :destroy
  has_many :videos, :order => "display_order", :dependent => :destroy, :class_name => "Terryblr::Video"

  #
  # Behaviours
  #

  #XXX acts_as_commentable
  accepts_nested_attributes_for :photos, :allow_destroy => true
  accepts_nested_attributes_for :videos, :allow_destroy => true, :reject_if => Proc.new{|v| v["url"].blank? }

  #
  # Validations
  #
  validates_inclusion_of :content_type, :in => @@content_types
  validates_inclusion_of :display_type, :in => @@display_types, :if => Proc.new {|c| c.content_type.photos? }
  validate :should_have_text,   :if => Proc.new {|c| c.content_type.text? }
  validate :should_have_photos, :if => Proc.new {|c| c.content_type.photos? }
  validate :should_have_video,  :if => Proc.new {|c| c.content_type.video? }

  #
  # Scopes
  #

  @@content_types.each do |type|
    scope type.pluralize, where(:content_type => type.to_s)
  end

  #
  # Callbacks
  #
  after_initialize :set_display_type

  def set_display_type
    self.display_type ||= @@display_types.first
  end

  before_save :fix_tiny_mce

  #
  # Class Methods
  #
  class << self

    def content_types
      @@content_types
    end

    def display_types
      @@display_types
    end
    
  end

  #
  # Instance Methods
  #
  def content_type
    @_content_type ||= ActiveSupport::StringInquirer.new(read_attribute(:content_type)) unless read_attribute(:content_type).blank?
  end

  def display_type
    @_display_type ||= ActiveSupport::StringInquirer.new(read_attribute(:display_type)) unless read_attribute(:display_type).blank?
  end

  def content_types
    self.class.content_types
  end

  private
  
  def should_have_text
    
  end

  def should_have_photos
    
  end

  def should_have_video
    
  end
  

  include Terryblr::Extendable
end

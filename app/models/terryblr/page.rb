class Terryblr::Page < Terryblr::Base

  include Terryblr::Base::Taggable
  include Terryblr::Base::AasmStates
  include Terryblr::Base::Validation
  
  #
  # Constants
  #

  #
  # Associatons
  #
  belongs_to :site, :class_name => "Terryblr::Site"
  belongs_to :author, :class_name => "Terryblr::User"
  belongs_to :last_editor, :class_name => "Terryblr::User"
  has_many :photos, :as => :photoable, :order => "display_order", :class_name => "Terryblr::Photo"
  has_many :messages, :as => :messagable, :class_name => "Terryblr::Message"

  #
  # Behaviours
  #

  accepts_nested_attributes_for :messages
  accepts_nested_attributes_for :photos, :allow_destroy => true

  #
  # Validations
  #
  validates_presence_of :title, :body, :slug, :unless => :pending? 
  validate :slug, :uniqueness => true, :if => :slug?, :scope => :site_id

  #
  # Scopes
  #
  scope :roots, where(:parent_id => nil)

  #
  # Callbacks
  #
  before_validation :update_slug
  before_save :fix_tiny_mce

  def update_slug
    # Set slug if not set or changed
    self.slug = title.to_s.parameterize if !slug? or (!new_record? && title_changed?)
  end

  #
  # Class Methods
  #
  class << self
    def base_class
      self
    end
  end

  #
  # Instance Methods
  #
  def children
    @children ||= self.class.find_all_by_parent_id(id)
  end

  def parent
    @parent ||= parent_of
  end

  def parents
    @parents ||= []
    return @parents unless @parents.empty?

    prnt = self
    while prnt.parent_id?
      prnt = parent_of(prnt)
      @parents << prnt
    end
    @parents
  end

  def root()
    return @root unless @root.nil?
    prnt = self.parent || self
    while prnt.parent_id?
      prnt = parent_of(prnt)
    end
    @root = prnt
  end

  private

  def do_publish
    update_attribute :published_at, Time.zone.now
  end

  def parent_of(page = self)
    page.parent_id? ? self.class.find(page.parent_id) : nil
  end

  include Terryblr::Extendable
end

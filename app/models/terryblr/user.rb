class Terryblr::User < Terryblr::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  begin
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable
  rescue NoMethodError
    puts "[WARNING] The Devise initializer seems to be missing. If you are generating `devise:install`, this is normal."
    def self.devise *args
    end
  end

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  
  #
  # Constants
  #

  #
  # Associatons
  #
  has_many :comments
  has_many :line_items
  has_many :cart_items, :class_name => "LineItem", :conditions => "order_id is null"
  has_many :orders
  has_many :likes
  
  #
  # Behvaiours
  #
  attr_accessible :first_name, :last_name, :admin
  # attr_accessible :twitter_token, :twitter_secret, :profile_pic_url, :fb_session_key
  
  #
  # Validations
  #
  validates :email, :presence => true, :uniqueness => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  

  #
  # Callbacks
  #

  #
  # Scopes
  #
  scope :admins, lambda { where(:admin => true) }
  
  #
  # Class Methods
  #
  class << self
    
    def base_class
      self
    end
    
    def build_admin props
      self.new (props || {}).merge :admin => true
    end
  end

  #
  # Instance Methods
  #
  def full_name
    [first_name, last_name].join(' ')
  end
  
  
  def add_to_cart(opts = {})
    product = opts[:product]
    size = opts[:size].to_s
    qty = opts[:qty].to_i
    return if !product or !product.is_a?(Product)

    # Look for exisiting item
    item = cart_items.detect{|i|i.product==product and i.product.size_for_name(size) }

    # Create if not found
    item = cart_items.build(:product => product, :size => size) if item.nil?

    # Update qty
    item.qty += qty
    
    item.save
    item
  end

  protected

  def password_required?
    !persisted? || password.present? || password_confirmation.present?
  end

  include Terryblr::Extendable
end

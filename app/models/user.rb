class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

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
  validates_uniqueness_of :email

  #
  # Scopes
  #
  scope :admins, where(:admin => true)
  
  #
  # Class Methods
  #
  class << self
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

end

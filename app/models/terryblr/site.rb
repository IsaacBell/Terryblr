class Terryblr::Site < Terryblr::Base

  #
  # Constants
  #

  #
  # Associatons
  #
  has_many :posts
  has_many :pages
  has_many :features

  #
  # Validations
  #
  validates :name, :presence => true, :uniqueness => true


  #
  # Scopes
  #

  #
  # Class Methods
  #
  class << self
    
    # Use www or go for the first one
    def default
      find_by_name('www') || first
    end
    
  end

  #
  # Instance Methods
  #
  def yes!
    update_attributes!(:value => 1)
  end
  
  def no!
    update_attributes!(:value => 0)
  end


  include Terryblr::Extendable
end
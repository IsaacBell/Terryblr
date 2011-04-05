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
  default_scope :order => "id asc"

  #
  # Class Methods
  #
  class << self
    
    # Use www or go for the first one
    def default
      find_by_name('www') || first || create(:name => 'www')
    end
    
  end

  include Terryblr::Extendable
end
class Terryblr::Link < Terryblr::Base

  #
  # Constants
  #

  #
  # Associatons
  #
  belongs_to :post

  #
  # Validations
  #
  validates :url, :presence => true, :url => true, :if => :url?

  #
  # Scopes
  #

  #
  # Class Methods
  #
  class << self
  end

  #
  # Instance Methods
  #

  include Terryblr::Extendable
end
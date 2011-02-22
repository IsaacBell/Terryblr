class Terryblr::Link < Terryblr::Base

  #
  # Constants
  #

  #
  # Associatons
  #
  belongs_to :post, :class_name => "Terryblr::Post"

  #
  # Validations
  #
  validates_presence_of :url
  validates_url_format_of :url

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

end
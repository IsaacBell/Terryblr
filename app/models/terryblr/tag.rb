class Terryblr::Tag < Terryblr::Base

  #
  # Constants
  #

  #
  # Associatons
  #

  #
  # Validations
  #
  validates_presence_of :name

  #
  # Scopes
  #

  #
  # Class Methods
  #
  class << self
    
    def sti_names
      ['Tag', 'Terryblr::Tag']
    end
    
  end

  #
  # Instance Methods
  #

end
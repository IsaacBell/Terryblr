class Terryblr::Like < Terryblr::Base

  #
  # Constants
  #

  #
  # Associations
  #
  belongs_to :likeable, :polymorphic => true, :counter_cache => true
  belongs_to :user

  #
  # Validations
  #
  validates_presence_of :user
  validates_uniqueness_of :user_id, :scope => [:likeable_type, :likeable_id]

  #
  # Scopes
  #
  default_scope order('created_at ASC')

  #
  # Class Methods
  #
  class << self
    
    def name
      'Like'
    end
    
  end

  #
  # Instance Methods
  #

end
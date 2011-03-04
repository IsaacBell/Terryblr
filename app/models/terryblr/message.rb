class Terryblr::Message < Terryblr::Base

  #
  # Constants
  #

  #
  # Associatons
  #
  belongs_to :messagable, :polymorphic => true
  belongs_to :user

  #
  # Validations
  #
  validates_presence_of :name, :email, :body, :messagable_type, :messagable_id
  validates_email_format_of :email

  #
  # Scopes
  #

  #
  # Class Methods
  #
  class << self
    
    def sti_names
      ['Message', 'Terryblr::Message']
    end
    
  end

  #
  # Instance Methods
  #

end
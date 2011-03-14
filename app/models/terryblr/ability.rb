class Terryblr::Ability
  include CanCan::Ability

  def initialize(user)
      # Define abilities for the passed in user here. For example:
      # doc: https://github.com/ryanb/cancan/wiki/Defining-Abilities
      user ||= Terryblr::User.new
      if user.admin?
        can :manage, :all
      end
  end
end

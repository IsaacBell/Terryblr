class Terryblr::Ability
  include CanCan::Ability

  # Define abilities for the passed in user here. For example:
  # doc: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  def initialize(user)
    user ||= Terryblr::User.new
    if user.admin?
      can :manage, :all
    elsif user.role == :editor
      can :read, :all
      can :create, Terryblr::User
      can :manage, Terryblr::Post
    elsif user.role == :redactor
      can :read, :all
      can :create, Terryblr::User
      can :create, Terryblr::Post
    end
  end

  include Terryblr::Extendable
end

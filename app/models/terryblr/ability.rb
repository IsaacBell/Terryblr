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
      can :manage, Terryblr::Page
    elsif user.role == :redactor
      can :read, :all
      can :create, Terryblr::User
      can :manage, Terryblr::Page
      can :manage, Terryblr::Post, :author => user
    end
  end

  include Terryblr::Extendable
end

class Abilities::CritiqueModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can :manage, Critique
    can :delete_all_critiques, User
    can :delete_all_reviews, User
  end
end

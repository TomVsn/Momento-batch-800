class AccomodationVotePolicy < ApplicationPolicy
  # class Scope < Scope
  #   # NOTE: Be explicit about which records you allow access to!
  #   def resolve
  #     scope.where(user: user)
  #   end
  # end

  def show?
    # record.user == user
    true
  end

  def create?
    true
  end

  def update?
    # record.trip.participants.user == user
    true
  end

  def destroy?
    true
  end
end

# ajouter ce matin
# autres record.participant.trip.participants.exists?(user: user)
# index record.participant.trip.participants.where?(user: user)

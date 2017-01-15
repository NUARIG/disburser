class SpecimenTypePolicy < ApplicationPolicy
  def index?
    user.system_administrator || record.repository.repository_administrator?(user)
  end

  def bulk_update?
    user.system_administrator || record.repository.repository_administrator?(user)
  end
end
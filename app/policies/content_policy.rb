class ContentPolicy < ApplicationPolicy
  def edit?
    user.system_administrator || record.repository_administrator?(user)
  end

  def update?
    user.system_administrator || record.repository_administrator?(user)
  end
end
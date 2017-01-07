class ContentPolicy < ApplicationPolicy
  def edit?
    user.system_administrator || record.repository_administator?(user)
  end

  def update?
    user.system_administrator || record.repository_administator?(user)
  end
end
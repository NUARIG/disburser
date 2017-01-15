class RepositoryPolicy < ApplicationPolicy
  def index?
    user.system_administrator || user.repository_administrator?
  end

  def new?
    user.system_administrator
  end

  def create?
    user.system_administrator
  end

  def edit?
    user.system_administrator || record.repository_administrator?(user)
  end

  def update?
    user.system_administrator || record.repository_administrator?(user)
  end
end
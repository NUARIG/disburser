class RepositoryUserPolicy < ApplicationPolicy
  def index?
    user.system_administrator || record.repository.repository_administrator?(user)
  end

  def new?
    user.system_administrator || record.repository.repository_administrator?(user)
  end

  def create?
    user.system_administrator || record.repository.repository_administrator?(user)
  end

  def edit?
    user.system_administrator || record.repository.repository_administrator?(user)
  end

  def update?
    user.system_administrator || record.repository.repository_administrator?(user)
  end
end
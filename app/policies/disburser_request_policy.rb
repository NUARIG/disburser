class DisburserRequestPolicy < ApplicationPolicy
  def admin?
    user.system_administrator || user.repository_administrator?
  end

  def index?
    !user.system_administrator && !user.repository_administrator?
  end

  def edit?
    user.system_administrator || record.repository.repository_administrator?(user) || record.mine?(user)
  end

  def update?
    user.system_administrator || record.repository.repository_administrator?(user) || record.mine?(user)
  end

  def download_file?
    user.system_administrator || record.repository.repository_administrator?(user) || record.mine?(user)
  end
end
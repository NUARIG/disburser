class DisburserRequestPolicy < ApplicationPolicy
  def coordinator?
    user.repository_coordinator?
  end

  def admin?
    user.system_administrator || user.repository_administrator?
  end

  def index?
    !user.system_administrator && !user.repository_administrator? && !user.repository_coordinator?
  end

  def edit?
    user.system_administrator || record.repository.repository_administrator?(user) || record.mine?(user)
  end

  def update?
    user.system_administrator || record.repository.repository_administrator?(user) || record.mine?(user)
  end

  def download_file?
    user.system_administrator || record.repository.repository_administrator?(user) || record.mine?(user) || record.repository.repository_coordinator?(user)
  end

  def status?
    record.repository.repository_coordinator?(user)
  end
end
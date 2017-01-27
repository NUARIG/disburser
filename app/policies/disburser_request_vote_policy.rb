class DisburserRequestVotePolicy < ApplicationPolicy
  def create?
    record.disburser_request.repository.committee_member?(user)
  end

  def update?
    record.disburser_request.repository.committee_member?(user) && record.mine?(user)
  end
end
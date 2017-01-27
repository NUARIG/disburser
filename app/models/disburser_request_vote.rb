class DisburserRequestVote < ApplicationRecord
  belongs_to :disburser_request
  belongs_to :committee_member, class_name: 'User', foreign_key: :committee_member_user_id
  validates_presence_of :committee_member_user_id, :vote

  DISBURSER_REQUEST_VOTE_TYPE_APPROVE = 'approve'
  DISBURSER_REQUEST_VOTE_TYPE_DENY = 'deny'
  DISBURSER_REQUEST_VOTE_TYPES = [DISBURSER_REQUEST_VOTE_TYPE_APPROVE, DISBURSER_REQUEST_VOTE_TYPE_DENY]

  scope :by_user, ->(user) do
    where(committee_member_user_id: user.id)
  end

  def mine?(user)
    committee_member == user
  end
end
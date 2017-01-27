require 'rails_helper'
require 'active_support'

RSpec.describe DisburserRequestVote, type: :model do
  it { should belong_to :disburser_request }
  it { should belong_to :committee_member }

  it { should validate_presence_of :committee_member_user_id }
  it { should validate_presence_of :vote }

  before(:each) do
    @moomin_repository = FactoryGirl.build(:repository, name: 'Moomin Repository')
    @moomintroll_user = FactoryGirl.create(:user, email: 'moomintroll@moomin.com', username: 'moomintroll', first_name: 'Moomintroll', last_name: 'Moomin')
    @little_my_user = FactoryGirl.create(:user, email: 'little_my@moomin.com', username: 'little_my', first_name: 'Little My', last_name: 'Moomin')
    @disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
  end

  it 'can return disburser request votes by user' do
    disburser_request_vote_1 = FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request,  committee_member: @moomintroll_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
    disburser_request_vote_2 = FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request,  committee_member: @little_my_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
    expect(DisburserRequestVote.by_user(@little_my_user)).to match_array([disburser_request_vote_2])
  end

  it 'knows if a disburser request vote is mine', focus: false do
    disburser_request_vote = FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request,  committee_member: @moomintroll_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
    expect(disburser_request_vote.mine?(@moomintroll_user)).to be_truthy
  end

  it 'knows if a disburser request vote is not mine', focus: false do
    disburser_request_vote = FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request,  committee_member: @little_my_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
    expect(disburser_request_vote.mine?(@moomintroll_user)).to be_falsy
  end
end
require 'rails_helper'
describe DisburserRequestVotesController, type: :request do
  before(:each) do
    @moomin_repository = FactoryGirl.create(:repository, name: 'Moomins')
    @peanuts_repository = FactoryGirl.create(:repository, name: 'Moomins')
    @paul_user = FactoryGirl.create(:northwestern_user, email: 'paulie@whitesox.com', username: 'pkonerko', first_name: 'Paul', last_name: 'Konerko')
    @moomintroll_user = FactoryGirl.create(:northwestern_user, email: 'moomintroll@moomin.com', username: 'moomintroll', first_name: 'Moomintroll', last_name: 'Moomin')
    @disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    @moomin_repository.repository_users.build(username: @moomintroll_user.username, committee: true)
    @moomin_repository.save!
  end

  describe 'regular user' do
    before(:each) do
      sign_in @paul_user
    end

    it 'should deny access to create a disburser request vote', focus: false do
      post disburser_request_disburser_request_votes_url(@disburser_request), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to update a disburser request vote', focus: false do
      disburser_request_vote = FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request,  committee_member: @moomintroll_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
      put disburser_request_disburser_request_vote_url(@disburser_request, disburser_request_vote), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end
  end

  describe 'system administrator user' do
    before(:each) do
      @paul_user.system_administrator = true
      @paul_user.save
      sign_in @paul_user
    end

    it 'should deny access to create a disburser request vote', focus: false do
      post disburser_request_disburser_request_votes_url(@disburser_request), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to update a disburser request vote', focus: false do
      disburser_request_vote = FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request,  committee_member: @moomintroll_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
      put disburser_request_disburser_request_vote_url(@disburser_request, disburser_request_vote), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end
  end

  describe 'repository administrator user' do
    before(:each) do
      @moomin_repository.repository_users.build(username: @paul_user.username, administrator: true)
      @moomin_repository.save!

      sign_in @paul_user
    end

    it 'should deny access to create a disburser request vote', focus: false do
      post disburser_request_disburser_request_votes_url(@disburser_request), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end


    it 'should deny access to update a disburser request vote', focus: false do
      disburser_request_vote = FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request,  committee_member: @moomintroll_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
      put disburser_request_disburser_request_vote_url(@disburser_request, disburser_request_vote), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end
  end

  describe 'repository data coordinator user' do
    before(:each) do
      @moomin_repository.repository_users.build(username: @paul_user.username, data_coordinator: true)
      @moomin_repository.save!

      sign_in @paul_user
    end

    it 'should deny access to create a disburser request vote', focus: false do
      post disburser_request_disburser_request_votes_url(@disburser_request), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to update a disburser request vote', focus: false do
      disburser_request_vote = FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request,  committee_member: @moomintroll_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
      put disburser_request_disburser_request_vote_url(@disburser_request, disburser_request_vote), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end
  end

  describe 'repository specimen coordinator user' do
    before(:each) do
      @moomin_repository.repository_users.build(username: @paul_user.username, specimen_coordinator: true)
      @moomin_repository.save!

      sign_in @paul_user
    end

    it 'should deny access to create a disburser request vote', focus: false do
      post disburser_request_disburser_request_votes_url(@disburser_request), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to update a disburser request vote', focus: false do
      disburser_request_vote = FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request,  committee_member: @moomintroll_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
      put disburser_request_disburser_request_vote_url(@disburser_request, disburser_request_vote), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end
  end

  describe 'repository committee member user' do
    before(:each) do
      @moomin_repository.repository_users.build(username: @paul_user.username, committee: true)
      @moomin_repository.save!

      sign_in @paul_user
    end

    it 'should allow access to create a disburser request vote', focus: false do
      post disburser_request_disburser_request_votes_url(@disburser_request), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(committee_disburser_requests_url)
    end

    it 'should allow access to update a disburser request vote', focus: false do
      disburser_request_vote = FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request,  committee_member: @paul_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
      put disburser_request_disburser_request_vote_url(@disburser_request, disburser_request_vote), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(committee_disburser_requests_url)
    end

    it 'should denny access to update a disburser request vote that is not mine', focus: false do
      disburser_request_vote = FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request,  committee_member: @moomintroll_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
      put disburser_request_disburser_request_vote_url(@disburser_request, disburser_request_vote), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end
  end
end
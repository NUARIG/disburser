require 'rails_helper'
describe DisburserRequestVotesController, type: :request do
  before(:each) do
    @moomin_repository = FactoryGirl.create(:repository, name: 'Moomins')
    @peanuts_repository = FactoryGirl.create(:repository, name: 'Moomins')
    @paul_user = FactoryGirl.create(:user, email: 'paulie@whitesox.com', username: 'pkonerko', first_name: 'Paul', last_name: 'Konerko')
    @moomintroll_user = FactoryGirl.create(:user, email: 'moomintroll@moomin.com', username: 'moomintroll', first_name: 'Moomintroll', last_name: 'Moomin')
    @disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    @harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold)
    @moomin_repository.repository_users.build(username: @harold[:username], committee: true)
    @moomin_repository.save!
    @harold_user = User.where(username: @harold[:username]).first
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
      disburser_request_vote = FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request,  committee_member: @harold_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
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
      disburser_request_vote = FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request,  committee_member: @harold_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
      put disburser_request_disburser_request_vote_url(@disburser_request, disburser_request_vote), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end
  end

  describe 'repository administrator user' do
    before(:each) do
      @littlemy = { username: 'littlemy', first_name: 'Little', last_name: 'My', email: 'littlemy@moomin.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@littlemy)
      @moomin_repository.repository_users.build(username: @littlemy[:username], administrator: true)
      @moomin_repository.save!
      @littlemy_user = User.where(username: @littlemy[:username]).first
      sign_in @littlemy_user
    end

    it 'should deny access to create a disburser request vote', focus: false do
      post disburser_request_disburser_request_votes_url(@disburser_request), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end


    it 'should deny access to update a disburser request vote', focus: false do
      disburser_request_vote = FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request,  committee_member: @harold_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
      put disburser_request_disburser_request_vote_url(@disburser_request, disburser_request_vote), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end
  end

  describe 'repository data coordinator user' do
    before(:each) do
      @littlemy = { username: 'littlemy', first_name: 'Little', last_name: 'My', email: 'littlemy@moomin.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@littlemy)
      @moomin_repository.repository_users.build(username: @littlemy[:username], data_coordinator: true)
      @moomin_repository.save!
      @littlemy_user = User.where(username: @littlemy[:username]).first
      sign_in @littlemy_user
    end

    it 'should deny access to create a disburser request vote', focus: false do
      post disburser_request_disburser_request_votes_url(@disburser_request), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to update a disburser request vote', focus: false do
      disburser_request_vote = FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request,  committee_member: @harold_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
      put disburser_request_disburser_request_vote_url(@disburser_request, disburser_request_vote), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end
  end

  describe 'repository specimen coordinator user' do
    before(:each) do
      @littlemy = { username: 'littlemy', first_name: 'Little', last_name: 'My', email: 'littlemy@moomin.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@littlemy)
      @moomin_repository.repository_users.build(username: @littlemy[:username], specimen_coordinator: true)
      @moomin_repository.save!
      @littlemy_user = User.where(username: @littlemy[:username]).first
      sign_in @littlemy_user
    end

    it 'should deny access to create a disburser request vote', focus: false do
      post disburser_request_disburser_request_votes_url(@disburser_request), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to update a disburser request vote', focus: false do
      disburser_request_vote = FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request,  committee_member: @harold_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
      put disburser_request_disburser_request_vote_url(@disburser_request, disburser_request_vote), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end
  end

  describe 'repository committee member user' do
    before(:each) do
      @littlemy = { username: 'littlemy', first_name: 'Little', last_name: 'My', email: 'littlemy@moomin.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@littlemy)
      @moomin_repository.repository_users.build(username: @littlemy[:username], committee: true)
      @moomin_repository.save!
      @littlemy_user = User.where(username: @littlemy[:username]).first
      sign_in @littlemy_user
    end

    it 'should allow access to create a disburser request vote', focus: false do
      post disburser_request_disburser_request_votes_url(@disburser_request), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(committee_disburser_requests_url)
    end

    it 'should allow access to update a disburser request vote', focus: false do
      disburser_request_vote = FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request,  committee_member: @littlemy_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
      put disburser_request_disburser_request_vote_url(@disburser_request, disburser_request_vote), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(committee_disburser_requests_url)
    end

    it 'should denny access to update a disburser request vote that is not mine', focus: false do
      disburser_request_vote = FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request,  committee_member: @harold_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
      put disburser_request_disburser_request_vote_url(@disburser_request, disburser_request_vote), params: { disburser_request_vote: { vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comment: 'Hello moomin!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end
  end
end
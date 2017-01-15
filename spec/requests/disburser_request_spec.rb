require 'rails_helper'
describe DisburserRequestsController, type: :request do
  before(:each) do
    @moomin_repository = FactoryGirl.create(:repository, name: 'Moomins', data: true, specimens: false)
    @peanuts_repository = FactoryGirl.create(:repository, name: 'Moomins', data: true, specimens: false)
    @paul_user = FactoryGirl.create(:user, email: 'paulie@whitesox.com', username: 'pkonerko', first_name: 'Paul', last_name: 'Konerko')
    @moomintroll_user = FactoryGirl.create(:user, email: 'moomintroll@moomin.com', username: 'moomintroll', first_name: 'Moomintroll', last_name: 'Moomin')
  end

  describe 'regular user' do
    before(:each) do
      sign_in @paul_user
    end

    it 'should allow access to index of disburser requests', focus: false do
      get disburser_requests_url
      expect(response).to have_http_status(:success)
    end

    it 'should not allow access to admin of disburser requests', focus: false do
      get admin_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access initiate a new disburser request', focus: false do
      get new_repository_disburser_request_url(@moomin_repository)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to create a disburser request', focus: false do
      post repository_disburser_requests_url(@moomin_repository), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', specimens: true,  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to edit a disburser request created by another user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to edit a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to update a disburser request created by another user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', specimens: true,  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to update a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', specimens: true,  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'system administrator user' do
    before(:each) do
      @paul_user.system_administrator = true
      @paul_user.save
      sign_in @paul_user
    end

    it 'should deny access to index of disburser requests', focus: false do
      get disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to admin of disburser requests', focus: false do
      get admin_disburser_requests_url
      expect(response).to have_http_status(:success)
    end

    it 'should allow access initiate a new disburser request', focus: false do
      get new_repository_disburser_request_url(@moomin_repository)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to create a disburser request', focus: false do
      post repository_disburser_requests_url(@moomin_repository), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', specimens: true,  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to edit a disburser request created by another user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to edit a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to update a disburser request created by another user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', specimens: true,  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to update a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', specimens: true,  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'repository administrator user' do
    before(:each) do
      @harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com', administator: true,  committee: false, specimen_resource: false, data_resource: false }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold)
      @moomin_repository.repository_users.build(username: @harold[:username], administrator: true)
      @moomin_repository.save!
      @harold_user = User.where(username: @harold[:username]).first
      sign_in @harold_user
    end

    it 'should deny access to index of disburser requests', focus: false do
      get disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to admin of disburser requests', focus: false do
      get admin_disburser_requests_url
      expect(response).to have_http_status(:success)
    end

    it 'should allow access initiate a new disburser request', focus: false do
      get new_repository_disburser_request_url(@moomin_repository)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to create a disburser request', focus: false do
      post repository_disburser_requests_url(@moomin_repository), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', specimens: true,  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to edit a disburser request created by another user for the repository of which the user is an administator', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to edit a disburser request created by another user for another repository of which the user is not an administator', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @peanuts_repository, submitter: @moomintroll_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to edit a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to update a disburser request created by another user for the repository of which the user is an administator', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', specimens: true,  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to update a disburser request created by another user for another repository of which the user is not an administator', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @peanuts_repository, submitter: @moomintroll_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', specimens: true,  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to update a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', specimens: true,  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end
  end
end
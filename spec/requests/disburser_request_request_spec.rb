require 'rails_helper'
describe DisburserRequestsController, type: :request do
  before(:each) do
    @moomin_repository = FactoryGirl.create(:repository, name: 'Moomins')
    @peanuts_repository = FactoryGirl.create(:repository, name: 'Moomins')
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

    it 'should deny access to admin of disburser requests', focus: false do
      get admin_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to data coordinator of disburser requests', focus: false do
      get data_coordinator_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to specimen coordinator of disburser requests', focus: false do
      get specimen_coordinator_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to committee of disburser requests', focus: false do
      get committee_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access initiate a new disburser request', focus: false do
      get new_repository_disburser_request_url(@moomin_repository)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to create a disburser request', focus: false do
      post repository_disburser_requests_url(@moomin_repository), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123',  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to edit a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to edit a disburser request created by another user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to update a disburser request created by another user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123',  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to edit a data disburser request status', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_data_status_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to edit a specimen disburser request status', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_specimen_status_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to edit a admin disburser request status', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_admin_status_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to edit a committee review', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_committee_review_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to update a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123',  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to data status a disburser request', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch data_status_disburser_request_url(disburser_request), params: { disburser_request: { data_status: DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to specimen status a disburser request', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch specimen_status_disburser_request_url(disburser_request), params: { disburser_request: { specimen_status: DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to admin status a disburser request', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch admin_status_disburser_request_url(disburser_request), params: { disburser_request: { status: DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to cancel a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch cancel_disburser_request_url(disburser_request)
      expect(response).to redirect_to(disburser_requests_url)
      expect(flash[:success]).to eq('You have successfully canceled the repository request.')
    end

    it 'should deny access to cancel a disburser request created by the user but not in a cancellable state', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      disburser_request.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
      disburser_request.status_user = @moomintroll_user
      disburser_request.save!
      patch cancel_disburser_request_url(disburser_request)
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

    it 'should allow access to index of disburser requests', focus: false do
      get disburser_requests_url
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to admin of disburser requests', focus: false do
      get admin_disburser_requests_url
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to data coordinator of disburser requests', focus: false do
      get data_coordinator_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to specimen coordinator of disburser requests', focus: false do
      get specimen_coordinator_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to committee of disburser requests', focus: false do
      get committee_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access initiate a new disburser request', focus: false do
      get new_repository_disburser_request_url(@moomin_repository)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to create a disburser request', focus: false do
      post repository_disburser_requests_url(@moomin_repository), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123',  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to edit a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to edit a disburser request created by another user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to edit a data disburser request status', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_data_status_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to edit a specimen disburser request status', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_specimen_status_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to edit a admin disburser request status', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_admin_status_disburser_request_url(disburser_request)
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to edit a committee review', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_committee_review_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to update a disburser request created by another user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123',  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to update a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123',  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to data status a disburser request', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch data_status_disburser_request_url(disburser_request), params: { disburser_request: { data_status: DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to specimen status a disburser request', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch specimen_status_disburser_request_url(disburser_request), params: { disburser_request: { specimen_status: DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to admin status a disburser request', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch admin_status_disburser_request_url(disburser_request), params: { disburser_request: { status: DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW } }
      expect(response).to redirect_to(admin_disburser_requests_url)
    end

    it 'should allow access to cancel a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch cancel_disburser_request_url(disburser_request)
      expect(response).to redirect_to(disburser_requests_url)
      expect(flash[:success]).to eq('You have successfully canceled the repository request.')
    end

    it 'should deny access to cancel a disburser request created by the user but not in a cancellable state', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      disburser_request.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
      disburser_request.status_user = @moomintroll_user
      disburser_request.save!
      patch cancel_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to cancel a disburser request not created by the user', focus: false  do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      patch cancel_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end
  end

  describe 'repository administrator user' do
    before(:each) do
      @harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com', administator: true,  committee: false, specimen_coordinator: false, data_coordinator: false }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold)
      @moomin_repository.repository_users.build(username: @harold[:username], administrator: true)
      @moomin_repository.save!
      @harold_user = User.where(username: @harold[:username]).first
      sign_in @harold_user
    end

    it 'should allow access to index of disburser requests', focus: false do
      get disburser_requests_url
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to admin of disburser requests', focus: false do
      get admin_disburser_requests_url
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to data coordinator of disburser requests', focus: false do
      get data_coordinator_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to specimen coordinator of disburser requests', focus: false do
      get specimen_coordinator_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to committee of disburser requests', focus: false do
      get committee_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access initiate a new disburser request', focus: false do
      get new_repository_disburser_request_url(@moomin_repository)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to create a disburser request', focus: false do
      post repository_disburser_requests_url(@moomin_repository), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123',  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to edit a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @harold_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to edit a disburser request created by another user for the repository of which the user is an administator', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to edit a disburser request created by another user for another repository of which the user is not an administator', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @peanuts_repository, submitter: @moomintroll_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to edit a data disburser request status', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @harold_user)
      get edit_data_status_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to edit a specimen disburser request status', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_specimen_status_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to edit a admin disburser request status', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_admin_status_disburser_request_url(disburser_request)
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to edit a committee review', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_committee_review_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to update a disburser request created by another user for the repository of which the user is an administator', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to update a disburser request created by another user for another repository of which the user is not an administator', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @peanuts_repository, submitter: @moomintroll_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to update a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to data status a disburser request', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch data_status_disburser_request_url(disburser_request), params: { disburser_request: { data_status: DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to specimen status a disburser request', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch specimen_status_disburser_request_url(disburser_request), params: { disburser_request: { specimen_status: DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to admin status a disburser request', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch admin_status_disburser_request_url(disburser_request), params: { disburser_request: { status: DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW } }
      expect(response).to redirect_to(admin_disburser_requests_url)
    end

    it 'should allow access to cancel a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @harold_user)
      patch cancel_disburser_request_url(disburser_request)
      expect(response).to redirect_to(disburser_requests_url)
      expect(flash[:success]).to eq('You have successfully canceled the repository request.')
    end

    it 'should deny access to cancel a disburser request created by the user but not in a cancellable state', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @harold_user)
      disburser_request.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
      disburser_request.status_user = @moomintroll_user
      disburser_request.save!
      patch cancel_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to cancel a disburser request not created by the user', focus: false  do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      patch cancel_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end
  end

  describe 'repository data coordinator user' do
    before(:each) do
      @harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold)
      @moomin_repository.repository_users.build(username: @harold[:username], administrator: false, data_coordinator: true)
      @moomin_repository.save!
      @harold_user = User.where(username: @harold[:username]).first
      sign_in @harold_user
    end

    it 'should allow access to index of disburser requests', focus: false do
      get disburser_requests_url
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to admin of disburser requests', focus: false do
      get admin_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to data coordinator of disburser requests', focus: false do
      get data_coordinator_disburser_requests_url
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to specimen coordinator of disburser requests', focus: false do
      get specimen_coordinator_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to committee of disburser requests', focus: false do
      get committee_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access initiate a new disburser request', focus: false do
      get new_repository_disburser_request_url(@moomin_repository)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to create a disburser request', focus: false do
      post repository_disburser_requests_url(@moomin_repository), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to edit a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @harold_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to edit a disburser request created by another user for the repository of which the user is an coordinator', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to edit a disburser request created by another user for another repository of which the user is not an administator', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @peanuts_repository, submitter: @moomintroll_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to edit a data disburser request status', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_data_status_disburser_request_url(disburser_request)
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to edit a admin disburser request status', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_admin_status_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to edit a specimen disburser request status', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_specimen_status_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to edit a committee review', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_committee_review_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to update a disburser request created by another user for the repository of which the user is an coordinator', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to update a disburser request created by another user for another repository of which the user is not an cooridnato', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @peanuts_repository, submitter: @moomintroll_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to update a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @harold_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to data status a disburser request', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch data_status_disburser_request_url(disburser_request), params: { disburser_request: { data_status: DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED } }
      expect(response).to redirect_to(data_coordinator_disburser_requests_url)
    end

    it 'should deny access to specimen status a disburser request', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch specimen_status_disburser_request_url(disburser_request), params: { disburser_request: { specimen_status: DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to admin status a disburser request', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch admin_status_disburser_request_url(disburser_request), params: { disburser_request: { status: DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to cancel a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @harold_user)
      patch cancel_disburser_request_url(disburser_request)
      expect(response).to redirect_to(disburser_requests_url)
      expect(flash[:success]).to eq('You have successfully canceled the repository request.')
    end

    it 'should deny access to cancel a disburser request created by the user but not in a cancellable state', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @harold_user)
      disburser_request.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
      disburser_request.status_user = @moomintroll_user
      disburser_request.save!
      patch cancel_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to cancel a disburser request not created by the user', focus: false  do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      patch cancel_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end
  end

  describe 'repository specimen coordinator user' do
    before(:each) do
      @harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold)
      @moomin_repository.repository_users.build(username: @harold[:username], administrator: false, specimen_coordinator: true)
      @moomin_repository.save!
      @harold_user = User.where(username: @harold[:username]).first
      sign_in @harold_user
    end

    it 'should allow access to index of disburser requests', focus: false do
      get disburser_requests_url
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to admin of disburser requests', focus: false do
      get admin_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to data coordinator of disburser requests', focus: false do
      get data_coordinator_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to specimen coordinator of disburser requests', focus: false do
      get specimen_coordinator_disburser_requests_url
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to committee of disburser requests', focus: false do
      get committee_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access initiate a new disburser request', focus: false do
      get new_repository_disburser_request_url(@moomin_repository)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to create a disburser request', focus: false do
      post repository_disburser_requests_url(@moomin_repository), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to edit a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @harold_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to edit a disburser request created by another user for the repository of which the user is an coordinator', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to edit a disburser request created by another user for another repository of which the user is not an administator', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @peanuts_repository, submitter: @moomintroll_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to edit a data disburser request status', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_data_status_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to edit a specimen disburser request status', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_specimen_status_disburser_request_url(disburser_request)
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to edit a committee review', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_committee_review_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to edit a admin disburser request status', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_admin_status_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to update a disburser request created by another user for the repository of which the user is an coordinator', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to update a disburser request created by another user for another repository of which the user is not an cooridnato', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @peanuts_repository, submitter: @moomintroll_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to update a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @harold_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123', feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to data status a disburser request', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch data_status_disburser_request_url(disburser_request), params: { disburser_request: { data_status: DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to specimen status a disburser request', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch specimen_status_disburser_request_url(disburser_request), params: { disburser_request: { specimen_status: DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED } }
      expect(response).to redirect_to(specimen_coordinator_disburser_requests_url)
    end

    it 'should deny access to admin status a disburser request', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch admin_status_disburser_request_url(disburser_request), params: { disburser_request: { status: DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to cancel a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @harold_user)
      patch cancel_disburser_request_url(disburser_request)
      expect(response).to redirect_to(disburser_requests_url)
      expect(flash[:success]).to eq('You have successfully canceled the repository request.')
    end

    it 'should deny access to cancel a disburser request created by the user but not in a cancellable state', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @harold_user)
      disburser_request.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
      disburser_request.status_user = @moomintroll_user
      disburser_request.save!
      patch cancel_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to cancel a disburser request not created by the user', focus: false  do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      patch cancel_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end
  end

  describe 'repository committee member user' do
    before(:each) do
      @harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold)
      @moomin_repository.repository_users.build(username: @harold[:username], committee: true)
      @moomin_repository.save!
      @harold_user = User.where(username: @harold[:username]).first
      sign_in @harold_user
    end

    it 'should allow access to index of disburser requests', focus: false do
      get disburser_requests_url
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to admin of disburser requests', focus: false do
      get admin_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to data coordinator of disburser requests', focus: false do
      get data_coordinator_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to specimen coordinator of disburser requests', focus: false do
      get specimen_coordinator_disburser_requests_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to committee of disburser requests', focus: false do
      get committee_disburser_requests_url
      expect(response).to have_http_status(:success)
    end

    it 'should allow access initiate a new disburser request', focus: false do
      get new_repository_disburser_request_url(@moomin_repository)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to create a disburser request', focus: false do
      post repository_disburser_requests_url(@moomin_repository), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123',  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to edit a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @harold_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to edit a disburser request created by another user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_repository_disburser_request_url(@moomin_repository, disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to update a disburser request created by another user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123',  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to edit a data disburser request status', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_data_status_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to edit a specimen disburser request status', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_specimen_status_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to edit a admin disburser request status', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_admin_status_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to edit a committee review', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      get edit_committee_review_disburser_request_url(disburser_request)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to update a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @harold_user)
      put repository_disburser_request_url(@moomin_repository, disburser_request), params: { disburser_request: { title: 'Moomin request', investigator: 'Moomin investigator', irb_number: '123',  feasibility: false, cohort_criteria: 'Moomin cohort criteria', data_for_cohort: 'Moomin data for cohort', methods_justifications: 'Moomin methods justifications' } }
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to data status a disburser request', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch data_status_disburser_request_url(disburser_request), params: { disburser_request: { data_status: DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to specimen status a disburser request', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch specimen_status_disburser_request_url(disburser_request), params: { disburser_request: { specimen_status: DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to admin status a disburser request', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @paul_user)
      patch admin_status_disburser_request_url(disburser_request), params: { disburser_request: { status: DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to cancel a disburser request created by the user', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @harold_user)
      patch cancel_disburser_request_url(disburser_request)
      expect(response).to redirect_to(disburser_requests_url)
      expect(flash[:success]).to eq('You have successfully canceled the repository request.')
    end

    it 'should deny access to cancel a disburser request created by the user but not in a cancellable state', focus: false do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @harold_user)
      disburser_request.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
      disburser_request.status_user = @moomintroll_user
      disburser_request.save!
      patch cancel_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to cancel a disburser request not created by the user', focus: false  do
      disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
      patch cancel_disburser_request_url(disburser_request)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end
  end
end
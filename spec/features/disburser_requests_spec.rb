require 'rails_helper'
RSpec.feature 'Disburser Requests', type: :feature do
  before(:each) do
    @moomin_repository = FactoryGirl.create(:repository, name: 'Moomins', public: true)
    @specimen_type_blood = 'Blood'
    @specimen_type_tissue = 'Tissue'
    @moomin_repository.specimen_types.build(name: @specimen_type_blood)
    @moomin_repository.specimen_types.build(name: @specimen_type_tissue)
    @moomin_repository.save!
    @white_sox_repository = FactoryGirl.create(:repository, name: 'White Sox', public: true)
    @moomintroll_user = FactoryGirl.create(:northwestern_user, email: 'moomintroll@moomin.com', username: 'moomintroll', first_name: 'Moomintroll', last_name: 'Moomin')
    @paul_user = FactoryGirl.create(:northwestern_user, email: 'paulie@whitesox.com', username: 'pkonerko', first_name: 'Paul', last_name: 'Konerko')
    @the_groke_user = FactoryGirl.create(:northwestern_user, email: 'thegroker@moomin.com', username: 'thegroke', first_name: 'The', last_name: 'Groke')
    @wilbur_wood_user = FactoryGirl.create(:northwestern_user, email: 'wilburwood@whitesox.com', username: 'wwood', first_name: 'Wilbur', last_name: 'Wood')
  end

  describe 'Seeing a list of disburser requests' do
    before(:each) do
      @disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Groke research', investigator: 'Groke', irb_number: '123', feasibility: 1, cohort_criteria: 'Groke cohort criteria', data_for_cohort: 'Groke data for cohort' )
      @disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Moomin research', investigator: 'Moominpapa', irb_number: '456', feasibility: 1, cohort_criteria: 'Momomin cohort criteria', data_for_cohort: 'Momomin data for cohort')
      @disburser_request_3 = FactoryGirl.create(:disburser_request, repository: @white_sox_repository, submitter: @paul_user, title: 'Sox baseball research', investigator: 'Nellie Fox', irb_number: '789', feasibility: 0, cohort_criteria: 'Sox cohort criteria', data_for_cohort: 'Sox data for cohort')
      @disburser_request_4 = FactoryGirl.create(:disburser_request, repository: @white_sox_repository, submitter: @moomintroll_user, title: 'White Sox research', investigator: 'Wilbur Wood', irb_number: '999', feasibility: 1, cohort_criteria: 'White Sox cohort criteria', data_for_cohort: 'White Sox data for cohort')
      FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request_2, committee_member: @the_groke_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
      FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request_3, committee_member: @wilbur_wood_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_DENY)
      FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request_4, committee_member: @the_groke_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
      FactoryGirl.create(:disburser_request_vote, disburser_request: @disburser_request_4, committee_member: @wilbur_wood_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_DENY)
    end

    scenario 'As a regular user and sorting', js: true, focus: false do
      @disburser_request_4.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_4.status_user = @moomintroll_user
      @disburser_request_4.save!

      @disburser_request_1.feasibility = 0
      @disburser_request_1.save!
      login_as(@moomintroll_user, scope: :northwestern_user)
      visit root_path

      expect(page).to have_selector('.menu li.requests', visible: true)
      expect(page).to_not have_selector('.menu li.admin_requests', visible: true)

      visit disburser_requests_path

      expect(all('.disburser_request').size).to eq(3)
      not_match_disburser_request(@disburser_request_3)
      match_disburser_request_row(@disburser_request_1, 0)
      match_disburser_request_row(@disburser_request_2, 1)
      match_disburser_request_row(@disburser_request_4, 2)

      click_link('Title')
      sleep(2)
      match_disburser_request_row(@disburser_request_4, 0)
      match_disburser_request_row(@disburser_request_2, 1)
      match_disburser_request_row(@disburser_request_1, 2)

      click_link('Title')
      sleep(1)
      match_disburser_request_row(@disburser_request_1, 0)
      match_disburser_request_row(@disburser_request_2, 1)
      match_disburser_request_row(@disburser_request_4, 2)

      click_link('Investigator')
      sleep(1)
      match_disburser_request_row(@disburser_request_1, 0)
      match_disburser_request_row(@disburser_request_2, 1)
      match_disburser_request_row(@disburser_request_4, 2)

      click_link('Investigator')
      sleep(1)
      match_disburser_request_row(@disburser_request_4, 0)
      match_disburser_request_row(@disburser_request_2, 1)
      match_disburser_request_row(@disburser_request_1, 2)

      click_link('IRB Number')
      sleep(1)
      match_disburser_request_row(@disburser_request_1, 0)
      match_disburser_request_row(@disburser_request_2, 1)
      match_disburser_request_row(@disburser_request_4, 2)

      click_link('IRB Number')
      sleep(1)
      match_disburser_request_row(@disburser_request_4, 0)
      match_disburser_request_row(@disburser_request_2, 1)
      match_disburser_request_row(@disburser_request_1, 2)

      click_link('Feasibility')
      sleep(1)
      match_disburser_request_row(@disburser_request_1, 0)
      match_disburser_request_row(@disburser_request_2, 1)
      match_disburser_request_row(@disburser_request_4, 2)

      click_link('Feasibility')
      sleep(1)
      match_disburser_request_row(@disburser_request_2, 0)
      match_disburser_request_row(@disburser_request_4, 1)
      match_disburser_request_row(@disburser_request_1, 2)

      click_link('Repository')
      sleep(1)
      match_disburser_request_row(@disburser_request_1, 0)
      match_disburser_request_row(@disburser_request_2, 1)
      match_disburser_request_row(@disburser_request_4, 2)

      click_link('Repository')
      sleep(1)
      match_disburser_request_row(@disburser_request_4, 0)
      match_disburser_request_row(@disburser_request_1, 1)
      match_disburser_request_row(@disburser_request_2, 2)

      click_link('Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_1, 0)
      match_disburser_request_row(@disburser_request_2, 1)
      match_disburser_request_row(@disburser_request_4, 2)

      click_link('Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_4, 0)
      match_disburser_request_row(@disburser_request_1, 1)
      match_disburser_request_row(@disburser_request_2, 2)

      @disburser_request_2.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_2.status_user = @moomintroll_user
      @disburser_request_2.save!

      click_link('Submitted')
      sleep(1)
      match_disburser_request_row(@disburser_request_4, 0)
      match_disburser_request_row(@disburser_request_2, 1)
      match_disburser_request_row(@disburser_request_1, 2)

      click_link('Submitted')
      sleep(1)
      match_disburser_request_row(@disburser_request_1, 0)
      match_disburser_request_row(@disburser_request_2, 1)
      match_disburser_request_row(@disburser_request_4, 2)

      within('.disburser_requests_header') do
        select(@moomin_repository.name, from: 'Repository')
      end

      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(2)

      match_disburser_request_row(@disburser_request_1, 0)
      match_disburser_request_row(@disburser_request_2, 1)

      visit disburser_requests_path

      within('.disburser_requests_header') do
        select(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, from: 'Status')
      end

      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(2)

      match_disburser_request_row(@disburser_request_2, 0)
      match_disburser_request_row(@disburser_request_4, 1)

      @disburser_request_1.data_status = DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED
      @disburser_request_1.status_user = @moomintroll_user
      @disburser_request_1.save!

      @disburser_request_1.specimen_status = DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED
      @disburser_request_1.status_user = @moomintroll_user
      @disburser_request_1.save!

      visit disburser_requests_path

      within('.disburser_requests_header') do
        select(DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED, from: 'Data Status')
      end

      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(1)

      match_disburser_request_row(@disburser_request_1, 0)

      visit disburser_requests_path

      within('.disburser_requests_header') do
        select('yes', from: 'Feasibility')
      end

      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(2)

      match_disburser_request_row(@disburser_request_2, 0)
      match_disburser_request_row(@disburser_request_4, 1)

      within('.disburser_requests_header') do
        select('no', from: 'Feasibility')
      end

      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(1)

      match_disburser_request_row(@disburser_request_1, 0)
    end

    scenario 'As a system administrator and sorting', js: true, focus: false do
      @disburser_request_1.feasibility = 0
      @disburser_request_1.save!
      @disburser_request_2.feasibility = 0
      @disburser_request_2.save!
      @disburser_request_4.feasibility = 0
      @disburser_request_4.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_4.status_user = @moomintroll_user
      @disburser_request_4.save!

      @disburser_request_4.data_status = DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED
      @disburser_request_4.status_user = @paul_user
      @disburser_request_4.save!
      @disburser_request_4.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
      @disburser_request_4.status_user = @moomintroll_user
      @disburser_request_4.save!

      @moomintroll_user.system_administrator = true
      @moomintroll_user
      login_as(@moomintroll_user, scope: :northwestern_user)
      visit root_path
      expect(page).to have_selector('.menu li.requests', visible: true)
      expect(page).to have_selector('.menu li.admin', visible: true)
      visit admin_disburser_requests_path

      expect(all('.disburser_request').size).to eq(1)
      match_disburser_request_row(@disburser_request_4, 0)

      [@disburser_request_1, @disburser_request_2, @disburser_request_3].each do |disburser_request|
        disburser_request.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
        disburser_request.status_user = @moomintroll_user
        disburser_request.save!
      end
      visit admin_disburser_requests_path
      sleep(1)

      match_administrator_disburser_request_row(@disburser_request_1, 0, 0, 0)
      match_administrator_disburser_request_row(@disburser_request_2, 1, 1, 0)
      match_administrator_disburser_request_row(@disburser_request_3, 2, 0, 1)
      match_administrator_disburser_request_row(@disburser_request_4, 3, 1, 1)

      click_link('Title')
      sleep(2)

      match_administrator_disburser_request_row(@disburser_request_4, 0, 1, 1)
      match_administrator_disburser_request_row(@disburser_request_3, 1, 0, 1)
      match_administrator_disburser_request_row(@disburser_request_2, 2, 1, 0)
      match_administrator_disburser_request_row(@disburser_request_1, 3, 0, 0)

      click_link('Title')
      sleep(2)
      match_administrator_disburser_request_row(@disburser_request_1, 0, 0, 0)
      match_administrator_disburser_request_row(@disburser_request_2, 1, 1, 0)
      match_administrator_disburser_request_row(@disburser_request_3, 2, 0, 1)
      match_administrator_disburser_request_row(@disburser_request_4, 3, 1, 1)

      click_link('Investigator')
      sleep(1)
      match_administrator_disburser_request_row(@disburser_request_1, 0, 0, 0)
      match_administrator_disburser_request_row(@disburser_request_2, 1, 1, 0)
      match_administrator_disburser_request_row(@disburser_request_3, 2, 0, 1)
      match_administrator_disburser_request_row(@disburser_request_4, 3, 1, 1)

      click_link('Investigator')
      sleep(1)
      match_administrator_disburser_request_row(@disburser_request_4, 0, 1, 1)
      match_administrator_disburser_request_row(@disburser_request_3, 1, 0, 1)
      match_administrator_disburser_request_row(@disburser_request_2, 2, 1, 0)
      match_administrator_disburser_request_row(@disburser_request_1, 3, 0, 0)

      click_link('IRB Number')
      sleep(1)
      match_administrator_disburser_request_row(@disburser_request_1, 0, 0, 0)
      match_administrator_disburser_request_row(@disburser_request_2, 1, 1, 0)
      match_administrator_disburser_request_row(@disburser_request_3, 2, 0, 1)
      match_administrator_disburser_request_row(@disburser_request_4, 3, 1, 1)

      click_link('IRB Number')
      sleep(1)
      match_administrator_disburser_request_row(@disburser_request_4, 0, 1, 1)
      match_administrator_disburser_request_row(@disburser_request_3, 1, 0, 1)
      match_administrator_disburser_request_row(@disburser_request_2, 2, 1, 0)
      match_administrator_disburser_request_row(@disburser_request_1, 3, 0, 0)

      click_link('Feasibility')
      sleep(1)
      match_administrator_disburser_request_row(@disburser_request_1, 0, 0, 0)
      match_administrator_disburser_request_row(@disburser_request_2, 1, 1, 0)
      match_administrator_disburser_request_row(@disburser_request_3, 2, 0, 1)
      match_administrator_disburser_request_row(@disburser_request_4, 3, 1, 1)

      click_link('Status')
      sleep(1)

      match_administrator_disburser_request_row(@disburser_request_4, 0, 1, 1)
      match_administrator_disburser_request_row(@disburser_request_1, 1, 0, 0)
      match_administrator_disburser_request_row(@disburser_request_2, 2, 1, 0)
      match_administrator_disburser_request_row(@disburser_request_3, 3, 0, 1)

      click_link('Status')
      sleep(1)
      match_administrator_disburser_request_row(@disburser_request_1, 0, 0, 0)
      match_administrator_disburser_request_row(@disburser_request_2, 1, 1, 0)
      match_administrator_disburser_request_row(@disburser_request_3, 2, 0, 1)
      match_administrator_disburser_request_row(@disburser_request_4, 3, 1, 1)

      click_link('Data Status')
      sleep(1)

      match_administrator_disburser_request_row(@disburser_request_1, 0, 0, 0)
      match_administrator_disburser_request_row(@disburser_request_2, 1, 1, 0)
      match_administrator_disburser_request_row(@disburser_request_3, 2, 0, 1)
      match_administrator_disburser_request_row(@disburser_request_4, 3, 1, 1)

      click_link('Data Status')
      sleep(1)
      match_administrator_disburser_request_row(@disburser_request_4, 0, 1, 1)
      match_administrator_disburser_request_row(@disburser_request_1, 1, 0, 0)
      match_administrator_disburser_request_row(@disburser_request_2, 2, 1, 0)
      match_administrator_disburser_request_row(@disburser_request_3, 3, 0, 1)

      submitted_status_detail = @disburser_request_1.status_detail(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
      submitted_status_detail.created_at = Date.today - 4
      submitted_status_detail.save!
      @disburser_request_1.reload

      submitted_status_detail = @disburser_request_2.status_detail(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
      submitted_status_detail.created_at = Date.today - 3
      submitted_status_detail.save!
      @disburser_request_2.reload

      submitted_status_detail = @disburser_request_3.status_detail(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
      submitted_status_detail.created_at = Date.today - 2
      submitted_status_detail.save!
      @disburser_request_3.reload

      click_link('Submitted')
      sleep(1)

      match_administrator_disburser_request_row(@disburser_request_1, 0, 0, 0)
      match_administrator_disburser_request_row(@disburser_request_2, 1, 1, 0)
      match_administrator_disburser_request_row(@disburser_request_3, 2, 0, 1)
      match_administrator_disburser_request_row(@disburser_request_4, 3, 1, 1)

      click_link('Submitted')
      sleep(1)
      match_administrator_disburser_request_row(@disburser_request_4, 0, 1, 1)
      match_administrator_disburser_request_row(@disburser_request_3, 1, 0, 1)
      match_administrator_disburser_request_row(@disburser_request_2, 2, 1, 0)
      match_administrator_disburser_request_row(@disburser_request_1, 3, 0, 0)

      @disburser_request_2.feasibility = 1
      @disburser_request_2.save!
      @disburser_request_4.feasibility = 1
      @disburser_request_4.save!

      visit admin_disburser_requests_path
      sleep(1)
      expect(all('.disburser_request').size).to eq(2)

      match_administrator_disburser_request_row(@disburser_request_1, 0, 0, 0)
      match_administrator_disburser_request_row(@disburser_request_3, 1, 0, 1)

      within('.disburser_requests_header') do
        select(@moomin_repository.name, from: 'Repository')
      end

      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(1)

      match_administrator_disburser_request_row(@disburser_request_1, 0, 0, 0)

      visit admin_disburser_requests_path

      within('.disburser_requests_header') do
        select(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, from: 'Status')
      end

      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(2)

      match_administrator_disburser_request_row(@disburser_request_1, 0, 0, 0)
      match_administrator_disburser_request_row(@disburser_request_3, 1, 0, 1)

      @disburser_request_1.data_status = DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED
      @disburser_request_1.status_user = @moomintroll_user
      @disburser_request_1.save!

      visit admin_disburser_requests_path

      within('.disburser_requests_header') do
        select(DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED, from: 'Data Status')
      end

      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(1)

      match_administrator_disburser_request_row(@disburser_request_1, 0, 0, 0)

      visit admin_disburser_requests_path

      within('.disburser_requests_header') do
        select('yes', from: 'Feasibility')
      end

      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(2)

      match_administrator_disburser_request_row(@disburser_request_2, 0, 1, 0)
      match_administrator_disburser_request_row(@disburser_request_4, 1, 1, 1)

      within('.disburser_requests_header') do
        select('no', from: 'Feasibility')
      end

      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(2)

      match_administrator_disburser_request_row(@disburser_request_1, 0, 0, 0)
      match_administrator_disburser_request_row(@disburser_request_3, 1, 0, 1)
    end

    scenario 'As a repository administrator and sorting', js: true, focus: false do
      @disburser_request_5 = FactoryGirl.create(:disburser_request, repository: @white_sox_repository, submitter: @paul_user, title: 'White Sox z research', investigator: 'Wilbur Woodz', irb_number: '999', cohort_criteria: 'White Sox z cohort criteria', data_for_cohort: 'White Sox z data for cohort', feasibility: 0)
      harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(harold)
      @white_sox_repository.repository_users.build(username: 'hbaines', administrator: true)
      @white_sox_repository.save!
      harold_user = User.where(username: 'hbaines').first

      login_as(harold_user, scope: :northwestern_user)
      visit root_path
      expect(page).to have_selector('.menu li.requests', visible: true)
      expect(page).to have_selector('.menu li.admin', visible: true)
      visit admin_disburser_requests_path
      expect(all('.disburser_request').size).to eq(0)
      [@disburser_request_3, @disburser_request_4, @disburser_request_5].each do |disburser_request|
        disburser_request.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
        disburser_request.status_user = @moomintroll_user
        disburser_request.save!
      end
      visit admin_disburser_requests_path
      expect(all('.disburser_request').size).to eq(2)

      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)
    end

    scenario 'As a data coordinator and sorting', js: true, focus: false do
      @disburser_request_5 = FactoryGirl.create(:disburser_request, repository: @white_sox_repository, submitter: @paul_user, title: 'White Sox z research', investigator: 'Wilbur Woodz', irb_number: '999', feasibility: 1, cohort_criteria: 'White Sox z cohort criteria', data_for_cohort: 'White Sox z data for cohort')
      harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(harold)
      @white_sox_repository.repository_users.build(username: 'hbaines', administrator: false, data_coordinator: true)
      @white_sox_repository.save!
      harold_user = User.where(username: 'hbaines').first

      login_as(harold_user, scope: :northwestern_user)
      visit root_path
      expect(page).to have_selector('.menu li.requests', visible: true)
      expect(page).to have_selector('.menu li.data_coordinator', visible: true)
      visit data_coordinator_disburser_requests_path
      expect(all('.disburser_request').size).to eq(0)

      @disburser_request_1.status_user = @moomintroll_user
      @disburser_request_1.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_1.save!

      @disburser_request_3.status_user = @paul_user
      @disburser_request_3.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_3.save!

      @disburser_request_3.reload
      submitted_status_detail = @disburser_request_3.status_detail(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
      submitted_status_detail.created_at = Date.today - 2
      submitted_status_detail.save!
      @disburser_request_3.reload

      @disburser_request_5.status_user = @paul_user
      @disburser_request_5.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_5.save!

      @disburser_request_5.reload
      submitted_status_detail = @disburser_request_5.status_detail(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
      submitted_status_detail.created_at = Date.today - 1
      submitted_status_detail.save!
      @disburser_request_5.reload

      @disburser_request_5.status_user = @paul_user
      @disburser_request_5.status = DisburserRequest::DISBURSER_REQUEST_STATUS_APPROVED
      @disburser_request_5.save!

      visit data_coordinator_disburser_requests_path

      sleep(1)
      expect(all('.disburser_request').size).to eq(2)

      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)

      click_link('Title')
      sleep(1)
      match_disburser_request_row(@disburser_request_5, 0)
      match_disburser_request_row(@disburser_request_3, 1)

      click_link('Title')
      sleep(2)
      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)

      click_link('Investigator')
      sleep(1)
      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)

      click_link('Investigator')
      sleep(1)
      match_disburser_request_row(@disburser_request_5, 0)
      match_disburser_request_row(@disburser_request_3, 1)

      click_link('IRB Number')
      sleep(1)
      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)

      click_link('IRB Number')
      sleep(1)
      match_disburser_request_row(@disburser_request_5, 0)
      match_disburser_request_row(@disburser_request_3, 1)

      click_link('Feasibility')
      sleep(1)
      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)

      click_link('Feasibility')
      sleep(1)
      match_disburser_request_row(@disburser_request_5, 0)
      match_disburser_request_row(@disburser_request_3, 1)

      click_link('Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_5, 0)
      match_disburser_request_row(@disburser_request_3, 1)

      click_link('Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)

      click_link('Submitted')
      sleep(1)

      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)

      click_link('Submitted')
      sleep(1)
      match_disburser_request_row(@disburser_request_5, 0)
      match_disburser_request_row(@disburser_request_3, 1)

      @disburser_request_5.status_user = harold_user
      @disburser_request_5.data_status = DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED
      @disburser_request_5.save!

      visit data_coordinator_disburser_requests_path

      sleep(1)
      expect(all('.disburser_request').size).to eq(1)

      select('all', from: 'Data Status')
      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(2)

      click_link('Data Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)

      click_link('Data Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_5, 0)
      match_disburser_request_row(@disburser_request_3, 1)

      @disburser_request_5.status_user = harold_user
      @disburser_request_5.data_status = DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_NOT_STARTED
      @disburser_request_5.save!

      visit data_coordinator_disburser_requests_path

      within('.disburser_requests_header') do
        select(@white_sox_repository.name, from: 'Repository')
      end

      click_button('Search')
      sleep(2)
      expect(all('.disburser_request').size).to eq(2)

      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)

      within('.disburser_requests_header') do
        select(@moomin_repository.name, from: 'Repository')
      end

      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(0)

      visit data_coordinator_disburser_requests_path

      within('.disburser_requests_header') do
        select('yes', from: 'Feasibility')
      end

      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(1)

      match_disburser_request_row(@disburser_request_5, 0)

      within('.disburser_requests_header') do
        select('no', from: 'Feasibility')
      end

      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(1)

      match_disburser_request_row(@disburser_request_3, 0)
    end

    scenario 'As a specimen coordinator and sorting', js: true, focus: false do
      @disburser_request_5 = FactoryGirl.create(:disburser_request, repository: @white_sox_repository, submitter: @paul_user, title: 'White Sox z research', investigator: 'Wilbur Woodz', irb_number: '999', feasibility: 1,  cohort_criteria: 'White Sox z cohort criteria', data_for_cohort: 'White Sox z data for cohort')
      harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(harold)
      @white_sox_repository.repository_users.build(username: 'hbaines', administrator: false, specimen_coordinator: true)
      @white_sox_repository.save!
      harold_user = User.where(username: 'hbaines').first

      login_as(harold_user, scope: :northwestern_user)
      visit root_path
      expect(page).to have_selector('.menu li.requests', visible: true)
      expect(page).to have_selector('.menu li.specimen_coordinator', visible: true)
      visit specimen_coordinator_disburser_requests_path
      expect(all('.disburser_request').size).to eq(0)
      sleep(1)

      @disburser_request_1.status_user = @moomintroll_user
      @disburser_request_1.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_1.save!

      @disburser_request_1.status_user = harold_user
      @disburser_request_1.data_status = DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_DATA_CHECKED
      @disburser_request_1.save!

      @disburser_request_3.status_user = @paul_user
      @disburser_request_3.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_3.save!

      @disburser_request_3.reload
      submitted_status_detail = @disburser_request_3.status_detail(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
      submitted_status_detail.created_at = Date.today - 2
      submitted_status_detail.save!
      @disburser_request_3.reload

      @disburser_request_3.status_user = harold_user
      @disburser_request_3.data_status = DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_DATA_CHECKED
      @disburser_request_3.save!

      @disburser_request_5.status_user = @paul_user
      @disburser_request_5.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_5.save!

      @disburser_request_5.reload
      submitted_status_detail = @disburser_request_5.status_detail(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
      submitted_status_detail.created_at = Date.today - 1
      submitted_status_detail.save!
      @disburser_request_5.reload

      @disburser_request_5.status_user = harold_user
      @disburser_request_5.data_status = DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_DATA_CHECKED
      @disburser_request_5.save!

      visit specimen_coordinator_disburser_requests_path
      sleep(1)
      expect(all('.disburser_request').size).to eq(2)

      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)

      click_link('Title')
      sleep(1)
      match_disburser_request_row(@disburser_request_5, 0)
      match_disburser_request_row(@disburser_request_3, 1)

      click_link('Title')
      sleep(2)
      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)

      click_link('Investigator')
      sleep(1)
      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)

      click_link('Investigator')
      sleep(1)
      match_disburser_request_row(@disburser_request_5, 0)
      match_disburser_request_row(@disburser_request_3, 1)

      click_link('IRB Number')
      sleep(1)
      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)

      click_link('IRB Number')
      sleep(1)
      match_disburser_request_row(@disburser_request_5, 0)
      match_disburser_request_row(@disburser_request_3, 1)

      click_link('Feasibility')
      sleep(1)
      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)

      click_link('Feasibility')
      sleep(1)
      match_disburser_request_row(@disburser_request_5, 0)
      match_disburser_request_row(@disburser_request_3, 1)

      click_link('Submitted')
      sleep(1)
      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)

      click_link('Submitted')
      sleep(1)
      match_disburser_request_row(@disburser_request_5, 0)
      match_disburser_request_row(@disburser_request_3, 1)

      @disburser_request_5.status_user = @paul_user
      @disburser_request_5.status = DisburserRequest::DISBURSER_REQUEST_STATUS_APPROVED
      @disburser_request_5.save!

      visit specimen_coordinator_disburser_requests_path
      sleep(1)

      click_link('Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_5, 0)
      match_disburser_request_row(@disburser_request_3, 1)

      click_link('Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)

      @disburser_request_5.status_user = harold_user
      @disburser_request_5.specimen_status = DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED
      @disburser_request_5.save!

      visit specimen_coordinator_disburser_requests_path
      sleep(1)

      expect(all('.disburser_request').size).to eq(1)

      select('all', from: 'Specimen Status')
      click_button('Search')
      sleep(1)

      expect(all('.disburser_request').size).to eq(2)

      click_link('Specimen Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_5, 0)
      match_disburser_request_row(@disburser_request_3, 1)

      click_link('Specimen Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)

      @disburser_request_5.status_user = harold_user
      @disburser_request_5.data_status = DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_INSUFFICIENT_DATA
      @disburser_request_5.save!

      select('all', from: 'Data Status')
      click_button('Search')
      sleep(1)

      expect(all('.disburser_request').size).to eq(2)

      click_link('Data Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)


      click_link('Data Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_5, 0)
      match_disburser_request_row(@disburser_request_3, 1)

      @moomin_repository.repository_users.build(username: 'hbaines', administrator: false, specimen_coordinator: true)
      @moomin_repository.save!

      visit specimen_coordinator_disburser_requests_path

      match_disburser_request_row(@disburser_request_1, 0)
      match_disburser_request_row(@disburser_request_3, 1)


      within('.disburser_requests_header') do
        select(@white_sox_repository.name, from: 'Repository')
      end

      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(1)

      match_disburser_request_row(@disburser_request_3, 0)

      visit specimen_coordinator_disburser_requests_path

      within('.disburser_requests_header') do
        select('yes', from: 'Feasibility')
      end

      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(1)

      match_disburser_request_row(@disburser_request_1, 0)

      within('.disburser_requests_header') do
        select('no', from: 'Feasibility')
      end

      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(1)

      match_disburser_request_row(@disburser_request_3, 0)
    end

    scenario 'As a committee member and sorting', js: true, focus: false do
      [@disburser_request_1, @disburser_request_2, @disburser_request_3, @disburser_request_4].each do |disburser_request|
        disburser_request.feasibility = 0
        disburser_request.save!
      end

      @disburser_request_5 = FactoryGirl.create(:disburser_request, repository: @white_sox_repository, submitter: @moomintroll_user, title: 'White Sox z research', investigator: 'Wilbur Woodz', irb_number: '999', feasibility: 0,  cohort_criteria: 'White Sox z cohort criteria', data_for_cohort: 'White Sox z data for cohort')
      harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(harold)
      @white_sox_repository.repository_users.build(username: 'hbaines', committee: true)
      @white_sox_repository.save!
      harold_user = User.where(username: 'hbaines').first

      login_as(harold_user, scope: :northwestern_user)
      visit root_path
      expect(page).to have_selector('.menu li.requests', visible: true)
      expect(page).to have_selector('.menu li.committee', visible: true)
      visit committee_disburser_requests_path
      expect(all('.disburser_request').size).to eq(0)
      sleep(1)

      @disburser_request_1.status_user = @moomintroll_user
      @disburser_request_1.status = DisburserRequest::DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_1.save!

      @disburser_request_1.status_user = @moomintroll_user
      @disburser_request_1.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
      @disburser_request_1.save!


      @disburser_request_2.status_user = @moomintroll_user
      @disburser_request_2.status = DisburserRequest::DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_2.save!

      @disburser_request_2.status_user = @moomintroll_user
      @disburser_request_2.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
      @disburser_request_2.save!

      @disburser_request_3.status_user = @paul_user
      @disburser_request_3.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_3.save!

      @disburser_request_3.status_user = @paul_user
      @disburser_request_3.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
      @disburser_request_3.save!

      @disburser_request_3.reload
      submitted_status_detail = @disburser_request_3.status_detail(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
      submitted_status_detail.created_at = Date.today - 2
      submitted_status_detail.save!
      @disburser_request_3.reload

      @disburser_request_4.status_user = @paul_user
      @disburser_request_4.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_4.save!

      @disburser_request_5.status_user = @paul_user
      @disburser_request_5.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_5.save!

      @disburser_request_5.status_user = @paul_user
      @disburser_request_5.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
      @disburser_request_5.save!

      @disburser_request_5.reload
      submitted_status_detail = @disburser_request_5.status_detail(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
      submitted_status_detail.created_at = Date.today - 1
      submitted_status_detail.save!
      @disburser_request_5.reload

      visit committee_disburser_requests_path
      sleep(1)
      expect(all('.disburser_request').size).to eq(2)

      match_committee_disburser_request_row(@disburser_request_3, 0)
      match_committee_disburser_request_row(@disburser_request_5, 1)

      click_link('Title')
      sleep(1)
      match_committee_disburser_request_row(@disburser_request_5, 0)
      match_committee_disburser_request_row(@disburser_request_3, 1)

      click_link('Title')
      sleep(2)
      match_committee_disburser_request_row(@disburser_request_3, 0)
      match_committee_disburser_request_row(@disburser_request_5, 1)

      click_link('Submitter')
      sleep(1)
      match_committee_disburser_request_row(@disburser_request_3, 0)
      match_committee_disburser_request_row(@disburser_request_5, 1)

      click_link('Submitter')
      sleep(2)
      match_committee_disburser_request_row(@disburser_request_5, 0)
      match_committee_disburser_request_row(@disburser_request_3, 1)

      click_link('Investigator')
      sleep(1)
      match_committee_disburser_request_row(@disburser_request_3, 0)
      match_committee_disburser_request_row(@disburser_request_5, 1)

      click_link('Investigator')
      sleep(2)
      match_committee_disburser_request_row(@disburser_request_5, 0)
      match_committee_disburser_request_row(@disburser_request_3, 1)

      click_link('IRB Number')
      sleep(1)
      match_committee_disburser_request_row(@disburser_request_3, 0)
      match_committee_disburser_request_row(@disburser_request_5, 1)

      click_link('IRB Number')
      sleep(1)
      match_committee_disburser_request_row(@disburser_request_5, 0)
      match_committee_disburser_request_row(@disburser_request_3, 1)

      click_link('Submitted')
      sleep(1)

      match_committee_disburser_request_row(@disburser_request_3, 0)
      match_committee_disburser_request_row(@disburser_request_5, 1)

      click_link('Submitted')
      sleep(1)
      match_committee_disburser_request_row(@disburser_request_5, 0)
      match_committee_disburser_request_row(@disburser_request_3, 1)

      @disburser_request_5.status_user = @paul_user
      @disburser_request_5.status = DisburserRequest::DISBURSER_REQUEST_STATUS_APPROVED
      @disburser_request_5.save!

      visit committee_disburser_requests_path
      sleep(1)

      expect(all('.disburser_request').size).to eq(1)

      select('all', from: 'Status')
      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(2)

      click_link('Status')
      sleep(1)
      match_committee_disburser_request_row(@disburser_request_5, 0)
      match_committee_disburser_request_row(@disburser_request_3, 1)

      click_link('Status')
      sleep(1)
      match_committee_disburser_request_row(@disburser_request_3, 0)
      match_committee_disburser_request_row(@disburser_request_5, 1)

      select('all', from: 'Status')
      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(2)

      @disburser_request_5.status_user = @paul_user
      @disburser_request_5.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
      @disburser_request_5.save!

      visit committee_disburser_requests_path

      within('.disburser_requests_header') do
        select(@white_sox_repository.name, from: 'Repository')
      end

      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(2)

      match_committee_disburser_request_row(@disburser_request_3, 0)
      match_committee_disburser_request_row(@disburser_request_5, 1)

      within('.disburser_requests_header') do
        select(@moomin_repository.name, from: 'Repository')
      end

      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(0)
    end
  end

  scenario 'Creating a disburser request', js: true, focus: false  do
    peanuts_repository = FactoryGirl.create(:repository, name: 'Peanuts', public: false)
    login_as(@moomintroll_user, scope: :northwestern_user)
    visit disburser_requests_path
    expect(page).to have_selector('#new_repository_request_link', visible: false)
    within('.make_a_request') do
      select(@moomin_repository.name, from: 'Repository')
    end
    expect(page).to have_selector('#new_repository_request_link', visible: true)

    within('.make_a_request') do
      expect(page).to have_select('Repository', options: ['Select a repository', @moomin_repository.name, @white_sox_repository.name])
    end

    within('.make_a_request') do
      select('Select a repository', from: 'Repository')
    end
    expect(page).to have_selector('#new_repository_request_link', visible: false)
    within('.make_a_request') do
      select(@moomin_repository.name, from: 'Repository')
    end
    click_link('Make a request!')
    sleep(1)
    expect(page).to have_css('.submitter', text: @moomintroll_user.full_name)
    disburser_request = {}
    disburser_request[:investigator] = 'Sniff Moomin'
    disburser_request[:title] = 'Moomin Research'
    disburser_request[:irb_number] = '123'
    disburser_request[:feasibility] = true
    disburser_request[:cohort_criteria] = 'Moomin cohort criteria.'
    disburser_request[:data_for_cohort] = 'Moomin data for cohort.'
    fill_in('Investigator', with: disburser_request[:investigator])
    fill_in('Title', with: disburser_request[:title])
    fill_in('IRB Number', with: disburser_request[:irb_number])
    check('Feasibility?')
    attach_file('Methods/Justifications', Rails.root + 'spec/fixtures/files/methods_justificatons.docx')
    attach_file('Supporting Document', Rails.root + 'spec/fixtures/files/supporting_document.docx')
    fill_in('Cohort Criteria', with: disburser_request[:cohort_criteria])
    fill_in('Data for cohort', with: disburser_request[:data_for_cohort])

    scroll_to_bottom_of_the_page

    within('.disburser_request_details') do
      click_link('Add')
    end

    disburser_request_detail = {}
    disburser_request_detail[:specimen_type] = @specimen_type_tissue
    disburser_request_detail[:quantity] = '5'
    disburser_request_detail[:volume] = '10 mg'
    disburser_request_detail[:comments] = 'Moomin specimen'

    within(".disburser_request_detail:nth-of-type(1) .specimen_type") do
      find('select option', text: disburser_request_detail[:specimen_type]).select_option
    end

    within(".disburser_request_detail:nth-of-type(1) .quantity") do
      find('input').set(disburser_request_detail[:quantity])
    end

    within(".disburser_request_detail:nth-of-type(1) .volume") do
      find('input').set(disburser_request_detail[:volume])
    end

    within(".disburser_request_detail:nth-of-type(1) .comments") do
      find('textarea').set(disburser_request_detail[:comments])
    end
    scroll_to_bottom_of_the_page
    choose('Submitted')
    accept_confirm do
      click_button('Save')
    end
    sleep(1)
    disburser_request[:status] = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
    disburser_request[:submitted_at] = format_date(Date.today)
    match_disburser_request_row(disburser_request, 0)
    within('.disburser_request:nth-of-type(1)') do
      click_link('Edit')
    end
    sleep(1)

    expect(page.has_field?('Investigator', with: disburser_request[:investigator])).to be_truthy
    expect(page.has_field?('Title', with: disburser_request[:title])).to be_truthy
    expect(page.has_field?('IRB Number', with: disburser_request[:irb_number])).to be_truthy
    expect(page.has_checked_field?('Feasibility?')).to be_truthy
    expect(page).to have_css('a.methods_justifications_url', text: 'methods_justificatons.docx')
    expect(page).to have_css('a.supporting_document_url', text: 'supporting_document.docx')
    expect(page.has_field?('Cohort Criteria', with: disburser_request[:cohort_criteria])).to be_truthy
    expect(page.has_field?('Data for cohort', with: disburser_request[:data_for_cohort])).to be_truthy


    expect(all('.disburser_request_detail')[0].find('.specimen_type select', text: disburser_request_detail[:specimen_type])).to be_truthy
    expect(all('.disburser_request_detail')[0].find_field('Quantity', with: disburser_request_detail[:quantity])).to be_truthy
    expect(all('.disburser_request_detail')[0].find_field('Volume', with: disburser_request_detail[:volume])).to be_truthy
    expect(all('.disburser_request_detail')[0].find_field('Comments', with: disburser_request_detail[:comments])).to be_truthy
  end

  scenario 'Creating a disburser request for a request with a custom request form', js: true, focus: false do
    @moomin_repository.custom_request_form = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/custom_request_form.docx')))
    @moomin_repository.save
    login_as(@moomintroll_user, scope: :northwestern_user)
    visit disburser_requests_path
    within('.make_a_request') do
      select('Select a repository', from: 'Repository')
    end
    expect(page).to have_selector('#new_repository_request_link', visible: false)
    within('.make_a_request') do
      select(@moomin_repository.name, from: 'Repository')
    end
    click_link('Make a request!')
    sleep(1)
    disburser_request = {}
    disburser_request[:investigator] = 'Sniff Moomin'
    disburser_request[:title] = 'Moomin Research'
    disburser_request[:irb_number] = '123'
    disburser_request[:feasibility] = true
    expect(page).to have_css('.submitter', text: @moomintroll_user.full_name)
    fill_in('Investigator', with: disburser_request[:investigator])
    fill_in('Title', with: disburser_request[:title])
    fill_in('IRB Number', with: disburser_request[:irb_number])
    check('Feasibility?')
    attach_file('Custom Request Form', Rails.root + 'spec/fixtures/files/custom_request_form.docx')
    attach_file('Supporting Document', Rails.root + 'spec/fixtures/files/supporting_document.docx')

    scroll_to_bottom_of_the_page
    choose('Submitted')

    accept_confirm do
      click_button('Save')
    end

    sleep(1)
    disburser_request[:status] = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
    match_disburser_request_row(disburser_request, 0)
    within('.disburser_request:nth-of-type(1)') do
      click_link('Edit')
    end
    sleep(1)

    expect(page.has_field?('Investigator', with: disburser_request[:investigator])).to be_truthy
    expect(page.has_field?('Title', with: disburser_request[:title])).to be_truthy
    expect(page.has_field?('IRB Number', with: disburser_request[:irb_number])).to be_truthy
    expect(page.has_checked_field?('Feasibility?')).to be_truthy
    expect(page).to have_css('a.custom_request_form_url', text: 'custom_request_form.docx')
    expect(page).to have_css('a.supporting_document_url', text: 'supporting_document.docx')
  end

  scenario 'Creating a disburser request for a repository without specmen types setup', js: true, focus: false  do
    login_as(@moomintroll_user, scope: :northwestern_user)
    visit disburser_requests_path
    within('.make_a_request') do
      select(@white_sox_repository.name, from: 'Repository')
    end
    click_link('Make a request!')
    sleep(1)
    expect(page).to_not have_selector('#disburser_request_details')
  end

  scenario 'Creating a disburser request with validation', js: true, focus: false do
    login_as(@moomintroll_user, scope: :northwestern_user)
    visit disburser_requests_path
    within('.make_a_request') do
      select(@moomin_repository.name, from: 'Repository')
    end
    click_link('Make a request!')
    expect(page).to have_css('.submitter', text: @moomintroll_user.full_name)

    scroll_to_bottom_of_the_page
    within('.disburser_request_details') do
      click_link('Add')
    end

    disburser_request_detail = {}
    disburser_request_detail[:comments] = 'Moomin specimen'

    within(".disburser_request_detail:nth-of-type(1) .comments") do
      find('textarea').set(disburser_request_detail[:comments])
    end

    scroll_to_bottom_of_the_page
    accept_confirm do
      click_button('Save')
    end

    within(".flash .callout") do
      expect(page).to have_content('Failed to create repository request.')
    end
    expect(page).to have_css('.investigator .field_with_errors')
    expect(page).to have_css('.title .field_with_errors')
    expect(page).to have_css('.irb_number .field_with_errors')
    expect(page).to have_css('.methods_justifications .field_with_errors')
    expect(page).to_not have_css('.supporting_document .field_with_errors')
    expect(page).to have_css('.cohort_criteria .field_with_errors')
    expect(page).to have_css('.data_for_cohort .field_with_errors')

    attach_file('Methods/Justifications', Rails.root + 'spec/fixtures/files/methods_justificatons.docx')
    attach_file('Supporting Document', Rails.root + 'spec/fixtures/files/supporting_document.docx')

    scroll_to_bottom_of_the_page
    accept_confirm do
      click_button('Save')
    end

    expect(page).to have_css('.investigator .field_with_errors')
    expect(page).to have_css('.title .field_with_errors')
    expect(page).to have_css('.irb_number .field_with_errors')
    expect(page).to have_css('a.methods_justifications_url', text: 'methods_justificatons.docx')
    expect(page).to have_css('a.supporting_document_url', text: 'supporting_document.docx')
    expect(page).to have_css('.cohort_criteria .field_with_errors')
    expect(page).to have_css('.data_for_cohort .field_with_errors')
    expect(page).to have_css('.disburser_request_detail:nth-of-type(1) .specimen_type .field_with_errors')
    expect(page).to have_css('.disburser_request_detail:nth-of-type(1) .quantity .field_with_errors')
  end

  scenario 'Creating a disburser request with validation for a request with a custom request form', js: true, focus: false do
    @moomin_repository.custom_request_form = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/custom_request_form.docx')))
    @moomin_repository.save
    login_as(@moomintroll_user, scope: :northwestern_user)
    visit disburser_requests_path
    within('.make_a_request') do
      select(@moomin_repository.name, from: 'Repository')
    end
    click_link('Make a request!')
    expect(page).to have_css('.submitter', text: @moomintroll_user.full_name)
    scroll_to_bottom_of_the_page

    accept_confirm do
      click_button('Save')
    end

    within(".flash .callout") do
      expect(page).to have_content('Failed to create repository request.')
    end
    expect(page).to have_css('.investigator .field_with_errors')
    expect(page).to have_css('.title .field_with_errors')
    expect(page).to have_css('.irb_number .field_with_errors')
    expect(page).to_not have_css('.methods_justifications .field_with_errors')
    expect(page).to_not have_css('.cohort_criteria .field_with_errors')
    expect(page).to_not have_css('.data_for_cohort .field_with_errors')
    expect(page).to have_css('.custom_request_form .field_with_errors')
    expect(page).to_not have_css('.supporting_document .field_with_errors')

    attach_file('Custom Request Form', Rails.root + 'spec/fixtures/files/custom_request_form.docx')
    attach_file('Supporting Document', Rails.root + 'spec/fixtures/files/supporting_document.docx')

    scroll_to_bottom_of_the_page
    accept_confirm do
      click_button('Save')
    end

    expect(page).to have_css('.investigator .field_with_errors')
    expect(page).to have_css('.title .field_with_errors')
    expect(page).to have_css('.irb_number .field_with_errors')
    expect(page).to_not have_css('.methods_justifications .field_with_errors')
    expect(page).to_not have_css('.cohort_criteria .field_with_errors')
    expect(page).to_not have_css('.data_for_cohort .field_with_errors')
    expect(page).to have_css('a.custom_request_form_url', text: 'custom_request_form.docx')
    expect(page).to have_css('a.supporting_document_url', text: 'supporting_document.docx')
    expect(page).to_not have_css('.disburser_request_detail:nth-of-type(1) .specimen_type .field_with_errors')
    expect(page).to_not have_css('.disburser_request_detail:nth-of-type(1) .quantity .field_with_errors')
  end

  scenario 'Editing a disburser request', js: true, focus: false do
    disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Moomin research', investigator: 'Sniff Moomin', irb_number: '123', cohort_criteria: 'Moomin cohort criteria.', data_for_cohort: 'Moomin data for cohort.', feasibility: true, supporting_document: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/supporting_document.docx'))))
    disburser_request_detail = {}
    disburser_request_detail[:specimen_type] = @specimen_type_blood
    disburser_request_detail[:quantity] = '5'
    disburser_request_detail[:volume] = '10 mg'
    disburser_request_detail[:comments] = 'Moomin specimen'
    specimen_type = @moomin_repository.specimen_types.where(name: @specimen_type_blood).first
    disburser_request.disburser_request_details.build(specimen_type: specimen_type, quantity: disburser_request_detail[:quantity], volume: disburser_request_detail[:volume], comments: disburser_request_detail[:comments])
    disburser_request.save
    login_as(@moomintroll_user, scope: :northwestern_user)
    visit disburser_requests_path

    all('.disburser_request')[0].find('.edit_disburser_request_link').click
    sleep(1)

    expect(page.has_css?('.submitter', text: @moomintroll_user.full_name)).to be_truthy
    expect(page.has_css?('.submitter_email', text: @moomintroll_user.email)).to be_truthy
    expect(page.has_field?('Investigator', with: disburser_request[:investigator])).to be_truthy
    expect(page.has_field?('Title', with: disburser_request[:title])).to be_truthy
    expect(page.has_field?('IRB Number', with: disburser_request[:irb_number])).to be_truthy
    expect(page.has_checked_field?('Feasibility?')).to be_truthy
    expect(page).to have_css('a.methods_justifications_url', text: 'methods_justificatons.docx')
    expect(page).to have_css('a.supporting_document_url', text: 'supporting_document.docx')
    expect(page.has_field?('Cohort Criteria', with: disburser_request[:cohort_criteria])).to be_truthy
    expect(page.has_field?('Data for cohort', with: disburser_request[:data_for_cohort])).to be_truthy

    expect(all('.disburser_request_detail')[0].find('.specimen_type select', text: disburser_request_detail[:specimen_type])).to be_truthy
    expect(all('.disburser_request_detail')[0].find_field('Quantity', with: disburser_request_detail[:quantity])).to be_truthy
    expect(all('.disburser_request_detail')[0].find_field('Volume', with: disburser_request_detail[:volume])).to be_truthy
    expect(all('.disburser_request_detail')[0].find_field('Comments', with: disburser_request_detail[:comments])).to be_truthy

    sleep(1)

    disburser_request = {}
    disburser_request[:investigator] = 'Moominmama'
    disburser_request[:title] = 'Moominmama Research'
    disburser_request[:irb_number] = '456'
    disburser_request[:cohort_criteria] = 'Moominmama cohort criteria.'
    disburser_request[:data_for_cohort] = 'Moominmama data for cohort.'
    fill_in('Investigator', with: disburser_request[:investigator])
    fill_in('Title', with: disburser_request[:title])
    fill_in('IRB Number', with: disburser_request[:irb_number])
    uncheck('Feasibility?')

    within('.methods_justifications') do
      click_link('Remove')
    end

    within('.supporting_document') do
      click_link('Remove')
    end

    sleep(1)
    attach_file('Methods/Justifications', Rails.root + 'spec/fixtures/files/methods_justificatons2.docx')
    attach_file('Supporting Document', Rails.root + 'spec/fixtures/files/supporting_document2.docx')
    fill_in('Cohort Criteria', with: disburser_request[:cohort_criteria])
    fill_in('Data for cohort', with: disburser_request[:data_for_cohort])

    sleep(1)
    disburser_request_detail = {}
    disburser_request_detail[:specimen_type] = @specimen_type_tissue
    disburser_request_detail[:quantity] = '10'
    disburser_request_detail[:volume] = '20 mg'
    disburser_request_detail[:comments] = 'Moominmama specimen'

    scroll_to_bottom_of_the_page
    within('.disburser_request_details') do
      click_link('Add')
    end

    within(".disburser_request_detail:nth-of-type(2) .specimen_type") do
      find('select option', text: disburser_request_detail[:specimen_type]).select_option
    end

    within(".disburser_request_detail:nth-of-type(2) .quantity") do
      find('input').set(disburser_request_detail[:quantity])
    end

    within(".disburser_request_detail:nth-of-type(2) .volume") do
      find('input').set(disburser_request_detail[:volume])
    end

    within(".disburser_request_detail:nth-of-type(2) .comments") do
      find('textarea').set(disburser_request_detail[:comments])
    end

    expect(all('.disburser_request_detail')[1].find('.specimen_type select', text: disburser_request_detail[:specimen_type])).to be_truthy
    expect(all('.disburser_request_detail')[1].find_field('Quantity', with: disburser_request_detail[:quantity])).to be_truthy
    expect(all('.disburser_request_detail')[1].find_field('Volume', with: disburser_request_detail[:volume])).to be_truthy
    expect(all('.disburser_request_detail')[1].find_field('Comments', with: disburser_request_detail[:comments])).to be_truthy

    scroll_to_bottom_of_the_page
    accept_confirm do
      click_button('Save')
    end

    all('.disburser_request')[0].find('.edit_disburser_request_link').click
    sleep(1)

    expect(page.has_css?('.submitter', text: @moomintroll_user.full_name)).to be_truthy
    expect(page.has_css?('.submitter_email', text: @moomintroll_user.email)).to be_truthy
    expect(page.has_field?('Investigator', with: disburser_request[:investigator])).to be_truthy
    expect(page.has_field?('Title', with: disburser_request[:title])).to be_truthy
    expect(page.has_field?('IRB Number', with: disburser_request[:irb_number])).to be_truthy
    expect(page.has_unchecked_field?('Feasibility?')).to be_truthy
    expect(page).to have_css('a.methods_justifications_url', text: 'methods_justificatons2.docx')
    expect(page).to have_css('a.supporting_document_url', text: 'supporting_document2.docx')
    expect(page.has_field?('Cohort Criteria', with: disburser_request[:cohort_criteria])).to be_truthy
    expect(page.has_field?('Data for cohort', with: disburser_request[:data_for_cohort])).to be_truthy
    sleep(1)

    scroll_to_bottom_of_the_page
    within(".disburser_request_detail:nth-of-type(1)") do
      click_link('Remove')
    end
    accept_confirm do
      click_button('Save')
    end

    sleep(1)
    all('.disburser_request')[0].find('.edit_disburser_request_link').click
    sleep(1)
    expect(all('.disburser_request_detail').size).to eq(1)
    expect(all('.disburser_request_detail')[0].find('.specimen_type select', text: disburser_request_detail[:specimen_type])).to be_truthy
    expect(all('.disburser_request_detail')[0].find_field('Quantity', with: disburser_request_detail[:quantity])).to be_truthy
    expect(all('.disburser_request_detail')[0].find_field('Volume', with: disburser_request_detail[:volume])).to be_truthy
    expect(all('.disburser_request_detail')[0].find_field('Comments', with: disburser_request_detail[:comments])).to be_truthy
    sleep(1)
 end

 scenario 'Editing a disburser request with validation', js: true, focus: false do
   disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Moomin research', investigator: 'Sniff Moomin', irb_number: '123', cohort_criteria: 'Moomin cohort criteria.', data_for_cohort: 'Moomin data for cohort.', feasibility: false)
   disburser_request_detail = {}
   disburser_request_detail[:specimen_type] = @specimen_type_blood
   disburser_request_detail[:quantity] = '5'
   disburser_request_detail[:volume] = '10 mg'
   disburser_request_detail[:comments] = 'Moomin specimen'
   specimen_type = @moomin_repository.specimen_types.where(name: @specimen_type_blood).first
   disburser_request.disburser_request_details.build(specimen_type: specimen_type, quantity: disburser_request_detail[:quantity], volume: disburser_request_detail[:volume], comments: disburser_request_detail[:comments])
   disburser_request.save
   login_as(@moomintroll_user, scope: :northwestern_user)
   visit disburser_requests_path

   all('.disburser_request')[0].find('.edit_disburser_request_link').click
   sleep(1)

   fill_in('Investigator', with: nil)
   fill_in('Title', with: nil)
   fill_in('IRB Number', with: nil)
   within('.methods_justifications') do
     click_link('Remove')
   end
   sleep(1)
   fill_in('Cohort Criteria', with: nil)
   fill_in('Data for cohort', with: nil)

   within(".disburser_request_detail:nth-of-type(1) .specimen_type") do
     find('select option', text: 'Select a type').select_option
   end

   within(".disburser_request_detail:nth-of-type(1) .quantity") do
     find('input').set(nil)
   end

   within(".disburser_request_detail:nth-of-type(1) .volume") do
     find('input').set(nil)
   end

   within(".disburser_request_detail:nth-of-type(1) .comments") do
     find('textarea').set(nil)
   end
   scroll_to_bottom_of_the_page
   accept_confirm do
     click_button('Save')
   end

   sleep(1)
   expect(page).to have_css('.investigator .field_with_errors')
   expect(page).to have_css('.title .field_with_errors')
   expect(page).to have_css('.irb_number .field_with_errors')
   expect(page).to have_css('.methods_justifications .field_with_errors')
   expect(page).to_not have_css('.supporting_document .field_with_errors')
   expect(page).to have_css('.cohort_criteria .field_with_errors')
   expect(page).to have_css('.data_for_cohort .field_with_errors')
   expect(page).to have_css('.disburser_request_detail:nth-of-type(1) .specimen_type .field_with_errors')
   expect(page).to have_css('.disburser_request_detail:nth-of-type(1) .quantity .field_with_errors')
   sleep(1)
   check('Feasibility?')
   scroll_to_bottom_of_the_page
   accept_confirm do
     click_button('Save')
   end
   sleep(1)
   expect(page).to_not have_css('.irb_number .field_with_errors')
 end

 scenario 'Canceling a disburser request as a regular user', js: true, focus: false  do
   disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Moomin research', investigator: 'Sniff Moomin', irb_number: '123', cohort_criteria: 'Moomin cohort criteria.', data_for_cohort: 'Moomin data for cohort.', feasibility: false)
   expect(disburser_request.status).to eq(DisburserRequest::DISBURSER_REQUEST_STAUTS_DRAFT)

   login_as(@moomintroll_user, scope: :northwestern_user)
   visit disburser_requests_path

   all('.disburser_request')[0].find('.edit_disburser_request_link').click
   expect(page).to have_css('form.disburser_request_form_cancel')

   accept_confirm do
     click_button('Cancel Request')
   end
   sleep(1)
   disburser_request.reload
   expect(disburser_request.status).to eq(DisburserRequest::DISBURSER_REQUEST_STATUS_CANCELED)
   match_disburser_request_row(disburser_request, 0)
 end

 scenario 'Updating the status of a disburser request as a data coordinator', js: true, focus: false do
   disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Moomin research', investigator: 'Sniff Moomin', irb_number: '123', cohort_criteria: 'Moomin cohort criteria.', data_for_cohort: 'Moomin data for cohort.', feasibility: true, status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @moomintroll_user, supporting_document: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/supporting_document.docx'))))
   disburser_request_detail = {}
   disburser_request_detail[:specimen_type] = @specimen_type_blood
   disburser_request_detail[:quantity] = '5'
   disburser_request_detail[:volume] = '10 mg'
   disburser_request_detail[:comments] = 'Moomin specimen'
   specimen_type = @moomin_repository.specimen_types.where(name: @specimen_type_blood).first
   disburser_request.disburser_request_details.build(specimen_type: specimen_type, quantity: disburser_request_detail[:quantity], volume: disburser_request_detail[:volume], comments: disburser_request_detail[:comments])
   disburser_request.save
   disburser_request.reload
   expect(disburser_request.data_status).to eq(DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_NOT_STARTED)
   harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
   allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(harold)
   @moomin_repository.repository_users.build(username: 'hbaines', administrator: false, data_coordinator: true)
   @moomin_repository.save!
   harold_user = User.where(username: 'hbaines').first
   login_as(harold_user, scope: :northwestern_user)
   visit data_coordinator_disburser_requests_path

   expect(find("#disburser_request_#{disburser_request.id} .data_status")).to have_content(DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_NOT_STARTED)

   find("#disburser_request_#{disburser_request.id}").click_link('Update')

   select('Select a data status', from: 'Data Status')
   click_button('Save')
   sleep(1)
   expect(page).to have_css('.status_update .field_with_errors')
   expect(find(".status_update .error")).to have_content("can't be blank")

   expect(page.has_css?('.submitter', text: @moomintroll_user.full_name)).to be_truthy
   expect(page.has_css?('.submitter_email', text: @moomintroll_user.email)).to be_truthy
   expect(page).to have_css('.submitter', text: @moomintroll_user.full_name)
   expect(page).to have_css('.investigator', text: disburser_request[:investigator])
   expect(page).to have_css('.title', text: disburser_request[:title])
   expect(page).to have_css('.irb_number', text: disburser_request[:irb_number])
   expect(page.has_checked_field?('Feasibility?', disabled: true)).to be_truthy
   expect(page).to have_css('a.methods_justifications_url', text: 'methods_justificatons.docx')
   expect(page).to have_css('a.supporting_document_url', text: 'supporting_document.docx')
   expect(page.has_field?('Cohort Criteria', with: disburser_request[:cohort_criteria], disabled: true)).to be_truthy
   expect(page.has_field?('Data for cohort', with: disburser_request[:data_for_cohort], disabled: true)).to be_truthy

   disburser_request.disburser_request_details.each do |disburser_request_detail|
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .specimen_type")).to have_content(disburser_request_detail.specimen_type.name)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .quantity")).to have_content(disburser_request_detail.quantity)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .quantity")).to have_content(disburser_request_detail.quantity)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .volume")).to have_content(disburser_request_detail.volume)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .comments")).to have_content(disburser_request_detail.comments)
   end

   expect(all('.statuses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS).each do |disburser_request_status|
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   expect(all('.data_statuses .disburser_request_status').size).to eq(0)

   select(DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED, from: 'Data Status')
   comments = 'Help the moomins!'
   fill_in('Data Status Comments', with: comments)
   click_button('Save')
   sleep(1)
   expect(all('.disburser_request').size).to eq(0)
   select(DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED, from: 'Data Status')
   click_button('Search')
   sleep(1)
   expect(all('.disburser_request').size).to eq(1)
   expect(find("#disburser_request_#{disburser_request.id} .data_status")).to have_content(DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED)
   find("#disburser_request_#{disburser_request.id}").click_link('Update')
   sleep(1)

   expect(all('.statuses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS).each do |disburser_request_status|
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   expect(all('.data_statuses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_DATA_STATUS).each do |disburser_request_status|
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end
 end

 scenario 'Updating the status of a disburser request as a specimen coordinator', js: true, focus: false do
   disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Moomin research', investigator: 'Sniff Moomin', irb_number: '123', cohort_criteria: 'Moomin cohort criteria.', data_for_cohort: 'Moomin data for cohort.', feasibility: true, status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @moomintroll_user, supporting_document: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/supporting_document.docx'))))
   disburser_request_detail = {}
   disburser_request_detail[:specimen_type] = @specimen_type_blood
   disburser_request_detail[:quantity] = '5'
   disburser_request_detail[:volume] = '10 mg'
   disburser_request_detail[:comments] = 'Moomin specimen'
   specimen_type = @moomin_repository.specimen_types.where(name: @specimen_type_blood).first
   disburser_request.disburser_request_details.build(specimen_type: specimen_type, quantity: disburser_request_detail[:quantity], volume: disburser_request_detail[:volume], comments: disburser_request_detail[:comments])
   disburser_request.save
   disburser_request.reload
   expect(disburser_request.data_status).to eq(DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_NOT_STARTED)
   disburser_request.data_status = DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_DATA_CHECKED
   disburser_request.status_user = @paul_user
   disburser_request.save!
   harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
   allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(harold)
   @moomin_repository.repository_users.build(username: 'hbaines', administrator: false, specimen_coordinator: true)
   @moomin_repository.save!
   harold_user = User.where(username: 'hbaines').first
   login_as(harold_user, scope: :northwestern_user)
   visit specimen_coordinator_disburser_requests_path

   expect(find("#disburser_request_#{disburser_request.id} .data_status")).to have_content(DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_DATA_CHECKED)
   find("#disburser_request_#{disburser_request.id}").click_link('Update')
   select('Select a specimen status', from: 'Specimen Status')

   click_button('Save')
   sleep(1)
   expect(page).to have_css('.status_update .field_with_errors')
   expect(find(".status_update .error")).to have_content("can't be blank")

   expect(page.has_css?('.submitter', text: @moomintroll_user.full_name)).to be_truthy
   expect(page.has_css?('.submitter_email', text: @moomintroll_user.email)).to be_truthy
   expect(page).to have_css('.submitter', text: @moomintroll_user.full_name)
   expect(page).to have_css('.investigator', text: disburser_request[:investigator])
   expect(page).to have_css('.title', text: disburser_request[:title])
   expect(page).to have_css('.irb_number', text: disburser_request[:irb_number])
   expect(page.has_checked_field?('Feasibility?', disabled: true)).to be_truthy
   expect(page).to have_css('a.methods_justifications_url', text: 'methods_justificatons.docx')
   expect(page).to have_css('a.supporting_document_url', text: 'supporting_document.docx')
   expect(page.has_field?('Cohort Criteria', with: disburser_request[:cohort_criteria], disabled: true)).to be_truthy
   expect(page.has_field?('Data for cohort', with: disburser_request[:data_for_cohort], disabled: true)).to be_truthy

   disburser_request.disburser_request_details.each do |disburser_request_detail|
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .specimen_type")).to have_content(disburser_request_detail.specimen_type.name)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .quantity")).to have_content(disburser_request_detail.quantity)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .quantity")).to have_content(disburser_request_detail.quantity)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .volume")).to have_content(disburser_request_detail.volume)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .comments")).to have_content(disburser_request_detail.comments)
   end

   expect(all('.statuses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS).each do |disburser_request_status|
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   expect(all('.data_statuses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_DATA_STATUS).each do |disburser_request_status|
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   select(DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED, from: 'Specimen Status')
   comments = 'Help the moomins!'
   fill_in('Specimen Status Comments', with: comments)
   click_button('Save')
   sleep(1)
   expect(all('.disburser_request').size).to eq(0)
   select(DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED, from: 'Specimen Status')
   click_button('Search')
   sleep(1)
   expect(all('.disburser_request').size).to eq(1)
   expect(find("#disburser_request_#{disburser_request.id} .specimen_status")).to have_content(DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED)
   find("#disburser_request_#{disburser_request.id}").click_link('Update')
   sleep(1)

   expect(all('.statuses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS).each do |disburser_request_status|
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   expect(all('.data_statuses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_DATA_STATUS).each do |disburser_request_status|
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   expect(all('.specimen_statuses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_SPECIMEN_STATUS).each do |disburser_request_status|
     expect(find(".specimen_statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".specimen_statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".specimen_statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".specimen_statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end
 end

 scenario 'Updating the status of a disburser request as a repository administrator', js: true, focus: false do
   disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Moomin research', investigator: 'Sniff Moomin', irb_number: '123', cohort_criteria: 'Moomin cohort criteria.', data_for_cohort: 'Moomin data for cohort.', status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @moomintroll_user, feasibility: 0, supporting_document: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/supporting_document.docx'))))
   disburser_request_detail = {}
   disburser_request_detail[:specimen_type] = @specimen_type_blood
   disburser_request_detail[:quantity] = '5'
   disburser_request_detail[:volume] = '10 mg'
   disburser_request_detail[:comments] = 'Moomin specimen'
   specimen_type = @moomin_repository.specimen_types.where(name: @specimen_type_blood).first
   disburser_request.disburser_request_details.build(specimen_type: specimen_type, quantity: disburser_request_detail[:quantity], volume: disburser_request_detail[:volume], comments: disburser_request_detail[:comments])
   disburser_request.save
   disburser_request.reload
   expect(disburser_request.data_status).to eq(DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_NOT_STARTED)
   disburser_request_votes = []
   disburser_request_votes << FactoryGirl.create(:disburser_request_vote, disburser_request: disburser_request, committee_member: @the_groke_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comments: 'The groke says sure thing!')
   disburser_request_votes << FactoryGirl.create(:disburser_request_vote, disburser_request: disburser_request, committee_member: @wilbur_wood_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_DENY, comments: 'Wilbur does not like!')
   harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
   allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(harold)
   @moomin_repository.repository_users.build(username: 'hbaines', administrator: true)
   @moomin_repository.save!
   harold_user = User.where(username: 'hbaines').first
   login_as(harold_user, scope: :northwestern_user)
   visit admin_disburser_requests_path

   expect(find("#disburser_request_#{disburser_request.id} .status")).to have_content(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
   expect(find("#disburser_request_#{disburser_request.id} .data_status")).to have_content(DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_NOT_STARTED)
   expect(find("#disburser_request_#{disburser_request.id} .specimen_status")).to have_content(DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_NOT_STARTED)

   find("#disburser_request_#{disburser_request.id}").click_link('Edit')
   select('Select a status', from: 'Status')
   select('Select a data status', from: 'Data Status')
   select('Select a specimen status', from: 'Specimen Status')
   click_button('Save')
   sleep(1)
   expect(page).to have_css('.status_update .status .field_with_errors')
   expect(find(".status_update .status .error")).to have_content("can't be blank")

   expect(page).to have_css('.status_update .data_status .field_with_errors')
   expect(find(".status_update .data_status .error")).to have_content("can't be blank")

   expect(page).to have_css('.status_update .specimen_status .field_with_errors')
   expect(find(".status_update .specimen_status .error")).to have_content("can't be blank")

   expect(page.has_css?('.submitter', text: @moomintroll_user.full_name)).to be_truthy
   expect(page.has_css?('.submitter_email', text: @moomintroll_user.email)).to be_truthy
   expect(page.has_field?('Investigator', with: disburser_request[:investigator])).to be_truthy
   expect(page.has_field?('Title', with: disburser_request[:title])).to be_truthy
   expect(page.has_field?('IRB Number', with: disburser_request[:irb_number])).to be_truthy
   expect(page.has_checked_field?('Feasibility?')).to be_falsy
   expect(page).to have_css('a.methods_justifications_url', text: 'methods_justificatons.docx')
   expect(page).to have_css('a.supporting_document_url', text: 'supporting_document.docx')
   expect(page.has_field?('Cohort Criteria', with: disburser_request[:cohort_criteria])).to be_truthy
   expect(page.has_field?('Data for cohort', with: disburser_request[:data_for_cohort])).to be_truthy

   disburser_request.disburser_request_details.each do |disburser_request_detail|
     expect(all("#disburser_request_detail_#{disburser_request_detail.id}")[0].find('.specimen_type select', text: disburser_request_detail[:specimen_type])).to be_truthy
     expect(all("#disburser_request_detail_#{disburser_request_detail.id}")[0].find_field('Quantity', with: disburser_request_detail[:quantity])).to be_truthy
     expect(all("#disburser_request_detail_#{disburser_request_detail.id}")[0].find_field('Volume', with: disburser_request_detail[:volume])).to be_truthy
     expect(all("#disburser_request_detail_#{disburser_request_detail.id}")[0].find_field('Comments', with: disburser_request_detail[:comments])).to be_truthy
   end

   expect(all('.statuses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS).each do |disburser_request_status|
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   expect(all('.data_statuses .disburser_request_status').size).to eq(0)
   expect(all('.specimen_statuses .disburser_request_status').size).to eq(0)

   select(DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW, from: 'Status')
   comments = 'Help the moomins!'
   fill_in('Status Comments', with: comments)

   select(DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED, from: 'Data Status')
   data_status_comments = 'Help the moomins with data!'
   fill_in('Data Status Comments', with: data_status_comments)

   select(DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED, from: 'Specimen Status')
   specimen_status_comments = 'Help the moomins with specimens!'
   fill_in('Specimen Status Comments', with: specimen_status_comments)

   click_button('Save')

   expect(find("#disburser_request_#{disburser_request.id} .status")).to have_content(DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW)
   expect(find("#disburser_request_#{disburser_request.id} .data_status")).to have_content(DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED)
   expect(find("#disburser_request_#{disburser_request.id} .specimen_status")).to have_content(DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED)
   find("#disburser_request_#{disburser_request.id}").click_link('Edit')

   sleep(1)

   expect(all('.statuses .disburser_request_status').size).to eq(2)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS).each do |disburser_request_status|
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   expect(all('.data_statuses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_DATA_STATUS).each do |disburser_request_status|
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   expect(all('.specimen_statuses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_SPECIMEN_STATUS).each do |disburser_request_status|
     expect(find(".specimen_statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".specimen_statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".specimen_statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".specimen_statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   click_link('Vote History')
   disburser_request_votes.each do |disburser_request_vote|
     expect(find("#disburser_request_vote_#{disburser_request_vote.id} .date")).to have_content(disburser_request_vote.created_at.to_s(:date))
     expect(find("#disburser_request_vote_#{disburser_request_vote.id} .committee_member")).to have_content(disburser_request_vote.committee_member.full_name)
     expect(find("#disburser_request_vote_#{disburser_request_vote.id} .vote")).to have_content(disburser_request_vote.vote)
     expect(find("#disburser_request_vote_#{disburser_request_vote.id} .comments")).to have_content(disburser_request_vote.comments)
   end

   within('.supporting_document') do
     click_link('Remove')
   end

   scroll_to_bottom_of_the_page
   click_button('Save')
   sleep(1)
   expect(page).to_not have_css('a.supporting_document_url', text: 'supporting_document.docx')
 end

 scenario 'Updating the status of a disburser request as a repository administrator with a custom request form', js: true, focus: false do
   @moomin_repository.custom_request_form = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/custom_request_form.docx')))
   @moomin_repository.save
   disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Moomin research', investigator: 'Sniff Moomin', irb_number: '123', status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @moomintroll_user, feasibility: 0, use_custom_request_form: true, custom_request_form: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/custom_request_form.docx'))), supporting_document: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/supporting_document.docx'))))
   expect(disburser_request.data_status).to eq(DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_NOT_STARTED)
   disburser_request_votes = []
   disburser_request_votes << FactoryGirl.create(:disburser_request_vote, disburser_request: disburser_request, committee_member: @the_groke_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, comments: 'The groke says sure thing!')
   disburser_request_votes << FactoryGirl.create(:disburser_request_vote, disburser_request: disburser_request, committee_member: @wilbur_wood_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_DENY, comments: 'Wilbur does not like!')
   harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
   allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(harold)
   @moomin_repository.repository_users.build(username: 'hbaines', administrator: true)
   @moomin_repository.save!
   harold_user = User.where(username: 'hbaines').first
   login_as(harold_user, scope: :northwestern_user)
   visit admin_disburser_requests_path

   expect(find("#disburser_request_#{disburser_request.id} .status")).to have_content(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
   expect(find("#disburser_request_#{disburser_request.id} .data_status")).to have_content(DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_NOT_STARTED)
   expect(find("#disburser_request_#{disburser_request.id} .specimen_status")).to have_content(DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_NOT_STARTED)

   find("#disburser_request_#{disburser_request.id}").click_link('Edit')

   select('Select a status', from: 'Status')
   select('Select a data status', from: 'Data Status')
   select('Select a specimen status', from: 'Specimen Status')
   click_button('Save')

   sleep(1)
   expect(page).to have_css('.status_update .status .field_with_errors')
   expect(find(".status_update .status .error")).to have_content("can't be blank")

   expect(page).to have_css('.status_update .data_status .field_with_errors')
   expect(find(".status_update .data_status .error")).to have_content("can't be blank")

   expect(page).to have_css('.status_update .specimen_status .field_with_errors')
   expect(find(".status_update .specimen_status .error")).to have_content("can't be blank")

   expect(page.has_css?('.submitter', text: @moomintroll_user.full_name)).to be_truthy
   expect(page.has_css?('.submitter_email', text: @moomintroll_user.email)).to be_truthy
   expect(page.has_field?('Investigator', with: disburser_request[:investigator])).to be_truthy
   expect(page.has_field?('Title', with: disburser_request[:title])).to be_truthy
   expect(page.has_field?('IRB Number', with: disburser_request[:irb_number])).to be_truthy
   expect(page.has_checked_field?('Feasibility?')).to be_falsy
   sleep(10)
   expect(page).to have_css('a.custom_request_form_url', text: 'custom_request_form.docx')
   expect(page).to have_css('a.supporting_document_url', text: 'supporting_document.docx')
   expect(page.has_field?('Cohort Criteria', with: disburser_request[:cohort_criteria])).to be_falsy
   expect(page.has_field?('Data for cohort', with: disburser_request[:data_for_cohort])).to be_falsy
   expect(page).to_not have_css('.disburser_request_details')

   expect(all('.statuses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS).each do |disburser_request_status|
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   expect(all('.data_statuses .disburser_request_status').size).to eq(0)
   expect(all('.specimen_statuses .disburser_request_status').size).to eq(0)

   select(DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW, from: 'Status')
   comments = 'Help the moomins!'
   fill_in('Status Comments', with: comments)

   select(DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED, from: 'Data Status')
   data_status_comments = 'Help the moomins with data!'
   fill_in('Data Status Comments', with: data_status_comments)

   select(DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED, from: 'Specimen Status')
   specimen_status_comments = 'Help the moomins with specimens!'
   fill_in('Specimen Status Comments', with: specimen_status_comments)
   click_button('Save')

   expect(find("#disburser_request_#{disburser_request.id} .status")).to have_content(DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW)
   expect(find("#disburser_request_#{disburser_request.id} .data_status")).to have_content(DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED)
   expect(find("#disburser_request_#{disburser_request.id} .specimen_status")).to have_content(DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED)
   find("#disburser_request_#{disburser_request.id}").click_link('Edit')

   sleep(1)

   expect(all('.statuses .disburser_request_status').size).to eq(2)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS).each do |disburser_request_status|
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   expect(all('.data_statuses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_DATA_STATUS).each do |disburser_request_status|
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".data_statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   expect(all('.specimen_statuses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_SPECIMEN_STATUS).each do |disburser_request_status|
     expect(find(".specimen_statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".specimen_statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".specimen_statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".specimen_statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   click_link('Vote History')
   disburser_request_votes.each do |disburser_request_vote|
     expect(find("#disburser_request_vote_#{disburser_request_vote.id} .date")).to have_content(disburser_request_vote.created_at.to_s(:date))
     expect(find("#disburser_request_vote_#{disburser_request_vote.id} .committee_member")).to have_content(disburser_request_vote.committee_member.full_name)
     expect(find("#disburser_request_vote_#{disburser_request_vote.id} .vote")).to have_content(disburser_request_vote.vote)
     expect(find("#disburser_request_vote_#{disburser_request_vote.id} .comments")).to have_content(disburser_request_vote.comments)
   end

   within('.supporting_document') do
     click_link('Remove')
   end

   scroll_to_bottom_of_the_page
   click_button('Save')
   sleep(1)
   expect(page).to_not have_css('a.supporting_document_url', text: 'supporting_document.docx')
 end

 scenario 'Voting on a disburser request as a committee member', js: true, focus: false do
   disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Moomin research', investigator: 'Sniff Moomin', irb_number: '123', cohort_criteria: 'Moomin cohort criteria.', data_for_cohort: 'Moomin data for cohort.', status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @moomintroll_user, feasibility: 0, supporting_document: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/supporting_document.docx'))))
   disburser_request_detail = {}
   disburser_request_detail[:specimen_type] = @specimen_type_blood
   disburser_request_detail[:quantity] = '5'
   disburser_request_detail[:volume] = '10 mg'
   disburser_request_detail[:comments] = 'Moomin specimen'
   specimen_type = @moomin_repository.specimen_types.where(name: @specimen_type_blood).first
   disburser_request.disburser_request_details.build(specimen_type: specimen_type, quantity: disburser_request_detail[:quantity], volume: disburser_request_detail[:volume], comments: disburser_request_detail[:comments])
   disburser_request.save
   disburser_request.reload
   disburser_request.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
   disburser_request.status_user = @paul_user
   disburser_request.save!
   harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
   allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(harold)
   @moomin_repository.repository_users.build(username: 'hbaines', committee: true)
   @moomin_repository.save!
   harold_user = User.where(username: 'hbaines').first
   login_as(harold_user, scope: :northwestern_user)
   visit committee_disburser_requests_path
   find("#disburser_request_#{disburser_request.id}").click_link('Review')
   sleep(1)

   scroll_to_bottom_of_the_page

   click_button('Save')
   sleep(1)
   expect(page).to have_css(".vote .field_with_errors input[name='disburser_request_vote[vote]']")
   expect(find(".vote .error")).to have_content("can't be blank")

   expect(page.has_css?('.submitter', text: @moomintroll_user.full_name)).to be_truthy
   expect(page.has_css?('.submitter_email', text: @moomintroll_user.email)).to be_truthy
   expect(page).to have_css('.submitter', text: @moomintroll_user.full_name)
   expect(page).to have_css('.investigator', text: disburser_request[:investigator])
   expect(page).to have_css('.title', text: disburser_request[:title])
   expect(page).to have_css('.irb_number', text: disburser_request[:irb_number])
   expect(page.has_checked_field?('Feasibility?', disabled: true)).to be_falsy
   expect(page).to have_css('a.methods_justifications_url', text: 'methods_justificatons.docx')
   expect(page).to have_css('a.supporting_document_url', text: 'supporting_document.docx')
   expect(page.has_field?('Cohort Criteria', with: disburser_request[:cohort_criteria], disabled: true)).to be_truthy
   expect(page.has_field?('Data for cohort', with: disburser_request[:data_for_cohort], disabled: true)).to be_truthy

   disburser_request.disburser_request_details.each do |disburser_request_detail|
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .specimen_type")).to have_content(disburser_request_detail.specimen_type.name)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .quantity")).to have_content(disburser_request_detail.quantity)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .quantity")).to have_content(disburser_request_detail.quantity)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .volume")).to have_content(disburser_request_detail.volume)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .comments")).to have_content(disburser_request_detail.comments)
   end

   expect(all('.disburser_request_vote_history .disburser_request_vote').size).to eq(0)
   scroll_to_bottom_of_the_page
   choose('Approve')
   comments = 'Help the moomins!'
   fill_in('Vote Comments', with: comments)
   click_button('Save')
   sleep(1)
   expect(all('.disburser_request').size).to eq(0)
   select('all', from: 'Vote Status')
   click_button('Search')
   sleep(1)
   expect(all('.disburser_request').size).to eq(1)
   find("#disburser_request_#{disburser_request.id}").click_link('Review')
   sleep(1)

   expect(all('.disburser_request_vote_history .disburser_request_vote').size).to eq(1)

   disburser_request.disburser_request_votes.each do |disburser_request_vote|
     expect(find(".disburser_request_vote_history #disburser_request_vote_#{disburser_request_vote.id} .date")).to have_content(disburser_request_vote.created_at.to_s(:date))
     expect(find(".disburser_request_vote_history #disburser_request_vote_#{disburser_request_vote.id} .committee_member")).to have_content(disburser_request_vote.committee_member.full_name)
     expect(find(".disburser_request_vote_history #disburser_request_vote_#{disburser_request_vote.id} .vote")).to have_content(disburser_request_vote.vote)
     expect(find(".disburser_request_vote_history #disburser_request_vote_#{disburser_request_vote.id} .comments")).to have_content(disburser_request_vote.comments)
   end

   expect(find_field('Approve', checked: true)).to be_truthy
   expect(page.has_field?('Vote Comments', with: comments)).to be_truthy
 end
end

def match_disburser_request_row(disburser_request, index)
  if disburser_request.is_a?(Hash)
    expect(all('.disburser_request')[index].find('.submitted_at')).to have_content(disburser_request[:submitted_at])
  else
    expect(all('.disburser_request')[index].find('.submitted_at')).to have_content(format_date(disburser_request.submitted_at))
  end
  expect(all('.disburser_request')[index].find('.title')).to have_content(disburser_request[:title])
  expect(all('.disburser_request')[index].find('.investigator')).to have_content(disburser_request[:investigator])
  expect(all('.disburser_request')[index].find('.irb_number')).to have_content(disburser_request[:irb_number])
  expect(all('.disburser_request')[index].find('.feasibility')).to have_content(human_boolean(disburser_request[:feasibility]))
  expect(all('.disburser_request')[index].find('.status')).to have_content(disburser_request[:status])
  expect(all('.disburser_request')[index].find('.data_status')).to have_content(disburser_request[:data_status])
  expect(all('.disburser_request')[index].find('.specimen_status')).to have_content(disburser_request[:specimen_status])
end

def match_committee_disburser_request_row(disburser_request, index)
  expect(all('.disburser_request')[index].find('.submitted_at')).to have_content(format_date(disburser_request.submitted_at))
  expect(all('.disburser_request')[index].find('.title')).to have_content(disburser_request[:title])
  expect(all('.disburser_request')[index].find('.investigator')).to have_content(disburser_request[:investigator])
  expect(all('.disburser_request')[index].find('.irb_number')).to have_content(disburser_request[:irb_number])
  expect(all('.disburser_request')[index].find('.status')).to have_content(disburser_request[:status])
end

def match_administrator_disburser_request_row(disburser_request, index, approve_count, deny_count)
  expect(all('.disburser_request')[index].find('.submitted_at')).to have_content(format_date(disburser_request.submitted_at))
  expect(all('.disburser_request')[index].find('.title')).to have_content(disburser_request[:title])
  expect(all('.disburser_request')[index].find('.investigator')).to have_content(disburser_request[:investigator])
  expect(all('.disburser_request')[index].find('.irb_number')).to have_content(disburser_request[:irb_number])
  expect(all('.disburser_request')[index].find('.feasibility')).to have_content(human_boolean(disburser_request[:feasibility]))
  expect(all('.disburser_request')[index].find('.status')).to have_content(disburser_request[:status])
  expect(all('.disburser_request')[index].find('.data_status')).to have_content(disburser_request[:data_status])
  expect(all('.disburser_request')[index].find('.specimen_status')).to have_content(disburser_request[:specimen_status])
  expect(all('.disburser_request')[index].find('.approve')).to have_content(approve_count.to_s)
  expect(all('.disburser_request')[index].find('.deny')).to have_content(deny_count.to_s)
end

def not_match_disburser_request(disburser_request)
  expect(page).to_not have_content(disburser_request[:title])
end

def format_date(date)
  date.present? ? date.to_s(:date) : nil
end
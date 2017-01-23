require 'rails_helper'
RSpec.feature 'Disburser Requests', type: :feature do
  before(:each) do
    @moomin_repository = FactoryGirl.create(:repository, name: 'Moomins')
    @specimen_type_blood = 'Blood'
    @specimen_type_tissue = 'Tissue'
    @moomin_repository.specimen_types.build(name: @specimen_type_blood)
    @moomin_repository.specimen_types.build(name: @specimen_type_tissue)
    @moomin_repository.save!
    @white_sox_repository = FactoryGirl.create(:repository, name: 'White Sox')
    @moomintroll_user = FactoryGirl.create(:user, email: 'moomintroll@moomin.com', username: 'moomintroll', first_name: 'Moomintroll', last_name: 'Moomin')
    @paul_user = FactoryGirl.create(:user, email: 'paulie@whitesox.com', username: 'pkonerko', first_name: 'Paul', last_name: 'Konerko')
  end

  describe 'Seeing a list of disburser requests' do
    before(:each) do
      @disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Groke research', investigator: 'Groke', irb_number: '123', feasibility: 0, cohort_criteria: 'Groke cohort criteria', data_for_cohort: 'Groke data for cohort' )
      @disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Moomin research', investigator: 'Moominpapa', irb_number: '456', feasibility: 1, cohort_criteria: 'Momomin cohort criteria', data_for_cohort: 'Momomin data for cohort')
      @disburser_request_3 = FactoryGirl.create(:disburser_request, repository: @white_sox_repository, submitter: @paul_user, title: 'Sox baseball research', investigator: 'Nellie Fox', irb_number: '789', feasibility: 0, cohort_criteria: 'Sox cohort criteria', data_for_cohort: 'Sox data for cohort')
      @disburser_request_4 = FactoryGirl.create(:disburser_request, repository: @white_sox_repository, submitter: @moomintroll_user, title: 'White Sox research', investigator: 'Wilbur Wood', irb_number: '999', feasibility: 1, cohort_criteria: 'White Sox cohort criteria', data_for_cohort: 'White Sox data for cohort')
    end

    scenario 'As a regular user and sorting', js: true, focus: false do
      @disburser_request_4.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_4.status_user = @moomintroll_user
      @disburser_request_4.save!

      login_as(@moomintroll_user, scope: :user)
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
      sleep(1)
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
    end

    scenario 'As a system administrator and sorting', js: true, focus: false do
      @disburser_request_4.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_4.status_user = @moomintroll_user
      @disburser_request_4.save!

      @disburser_request_4.fulfillment_status = DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED
      @disburser_request_4.status_user = @paul_user
      @disburser_request_4.save!
      @disburser_request_4.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
      @disburser_request_4.status_user = @moomintroll_user
      @disburser_request_4.save!

      @moomintroll_user.system_administrator = true
      @moomintroll_user
      login_as(@moomintroll_user, scope: :user)
      visit root_path
      expect(page).to_not have_selector('.menu li.requests', visible: true)
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

      match_disburser_request_row(@disburser_request_1, 0)
      match_disburser_request_row(@disburser_request_2, 1)
      match_disburser_request_row(@disburser_request_3, 2)
      match_disburser_request_row(@disburser_request_4, 3)

      click_link('Title')
      sleep(1)
      match_disburser_request_row(@disburser_request_4, 0)
      match_disburser_request_row(@disburser_request_3, 1)
      match_disburser_request_row(@disburser_request_2, 2)
      match_disburser_request_row(@disburser_request_1, 3)

      click_link('Title')
      sleep(2)
      match_disburser_request_row(@disburser_request_1, 0)
      match_disburser_request_row(@disburser_request_2, 1)
      match_disburser_request_row(@disburser_request_3, 2)
      match_disburser_request_row(@disburser_request_4, 3)

      click_link('Investigator')
      sleep(1)
      match_disburser_request_row(@disburser_request_1, 0)
      match_disburser_request_row(@disburser_request_2, 1)
      match_disburser_request_row(@disburser_request_3, 2)
      match_disburser_request_row(@disburser_request_4, 3)

      click_link('Investigator')
      sleep(1)
      match_disburser_request_row(@disburser_request_4, 0)
      match_disburser_request_row(@disburser_request_3, 1)
      match_disburser_request_row(@disburser_request_2, 2)
      match_disburser_request_row(@disburser_request_1, 3)

      click_link('IRB Number')
      sleep(1)
      match_disburser_request_row(@disburser_request_1, 0)
      match_disburser_request_row(@disburser_request_2, 1)
      match_disburser_request_row(@disburser_request_3, 2)
      match_disburser_request_row(@disburser_request_4, 3)

      click_link('IRB Number')
      sleep(1)
      match_disburser_request_row(@disburser_request_4, 0)
      match_disburser_request_row(@disburser_request_3, 1)
      match_disburser_request_row(@disburser_request_2, 2)
      match_disburser_request_row(@disburser_request_1, 3)

      click_link('Feasibility')
      sleep(1)
      match_disburser_request_row(@disburser_request_1, 0)
      match_disburser_request_row(@disburser_request_3, 1)
      match_disburser_request_row(@disburser_request_2, 2)
      match_disburser_request_row(@disburser_request_4, 3)

      click_link('Feasibility')
      sleep(1)
      match_disburser_request_row(@disburser_request_2, 0)
      match_disburser_request_row(@disburser_request_4, 1)
      match_disburser_request_row(@disburser_request_1, 2)
      match_disburser_request_row(@disburser_request_3, 3)

      click_link('Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_4, 0)
      match_disburser_request_row(@disburser_request_1, 1)
      match_disburser_request_row(@disburser_request_2, 2)
      match_disburser_request_row(@disburser_request_3, 3)

      click_link('Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_1, 0)
      match_disburser_request_row(@disburser_request_2, 1)
      match_disburser_request_row(@disburser_request_3, 2)
      match_disburser_request_row(@disburser_request_4, 3)

      click_link('Fulfillment Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_1, 0)
      match_disburser_request_row(@disburser_request_2, 1)
      match_disburser_request_row(@disburser_request_3, 2)
      match_disburser_request_row(@disburser_request_4, 3)

      click_link('Fulfillment Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_4, 0)
      match_disburser_request_row(@disburser_request_1, 1)
      match_disburser_request_row(@disburser_request_2, 2)
      match_disburser_request_row(@disburser_request_3, 3)
    end

    scenario 'As a repository administrator and sorting', js: true, focus: false do
      @disburser_request_5 = FactoryGirl.create(:disburser_request, repository: @white_sox_repository, submitter: @paul_user, title: 'White Sox z research', investigator: 'Wilbur Woodz', irb_number: '999', cohort_criteria: 'White Sox z cohort criteria', data_for_cohort: 'White Sox z data for cohort')
      harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(harold)
      @white_sox_repository.repository_users.build(username: 'hbaines', administrator: true)
      @white_sox_repository.save!
      harold_user = User.where(username: 'hbaines').first

      login_as(harold_user, scope: :user)
      visit root_path
      expect(page).to_not have_selector('.menu li.requests', visible: true)
      expect(page).to have_selector('.menu li.admin', visible: true)
      visit admin_disburser_requests_path
      expect(all('.disburser_request').size).to eq(0)
      [@disburser_request_3, @disburser_request_4, @disburser_request_5].each do |disburser_request|
        disburser_request.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
        disburser_request.status_user = @moomintroll_user
        disburser_request.save!
      end
      visit admin_disburser_requests_path
      expect(all('.disburser_request').size).to eq(3)

      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_4, 1)
      match_disburser_request_row(@disburser_request_5, 2)
    end

    scenario 'As a data coordinator and sorting', js: true, focus: false do
      @disburser_request_5 = FactoryGirl.create(:disburser_request, repository: @white_sox_repository, submitter: @paul_user, title: 'White Sox z research', investigator: 'Wilbur Woodz', irb_number: '999', feasibility: 1, cohort_criteria: 'White Sox z cohort criteria', data_for_cohort: 'White Sox z data for cohort')
      harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(harold)
      @white_sox_repository.repository_users.build(username: 'hbaines', administrator: false, data_coordinator: true)
      @white_sox_repository.save!
      harold_user = User.where(username: 'hbaines').first

      login_as(harold_user, scope: :user)
      visit root_path
      expect(page).to_not have_selector('.menu li.requests', visible: true)
      expect(page).to have_selector('.menu li.data_coordinator', visible: true)
      visit data_coordinator_disburser_requests_path
      expect(all('.disburser_request').size).to eq(0)

      @disburser_request_1.status_user = @moomintroll_user
      @disburser_request_1.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_1.save!

      @disburser_request_3.status_user = @paul_user
      @disburser_request_3.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_3.save!

      @disburser_request_5.status_user = @paul_user
      @disburser_request_5.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_5.save!

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

      @disburser_request_5.status_user = harold_user
      @disburser_request_5.fulfillment_status = DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED
      @disburser_request_5.save!

      visit data_coordinator_disburser_requests_path

      sleep(1)
      expect(all('.disburser_request').size).to eq(1)

      select('all', from: 'Fulfillment Status')
      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(2)

      click_link('Fulfillment Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)

      click_link('Fulfillment Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_5, 0)
      match_disburser_request_row(@disburser_request_3, 1)
    end

    scenario 'As a specimen coordinator and sorting', js: true, focus: false do
      @disburser_request_5 = FactoryGirl.create(:disburser_request, repository: @white_sox_repository, submitter: @paul_user, title: 'White Sox z research', investigator: 'Wilbur Woodz', irb_number: '999', feasibility: 1,  cohort_criteria: 'White Sox z cohort criteria', data_for_cohort: 'White Sox z data for cohort')
      harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(harold)
      @white_sox_repository.repository_users.build(username: 'hbaines', administrator: false, specimen_coordinator: true)
      @white_sox_repository.save!
      harold_user = User.where(username: 'hbaines').first

      login_as(harold_user, scope: :user)
      visit root_path
      expect(page).to_not have_selector('.menu li.requests', visible: true)
      expect(page).to have_selector('.menu li.specimen_coordinator', visible: true)
      visit specimen_coordinator_disburser_requests_path
      expect(all('.disburser_request').size).to eq(0)
      sleep(1)

      @disburser_request_1.status_user = @moomintroll_user
      @disburser_request_1.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_1.save!

      @disburser_request_1.status_user = harold_user
      @disburser_request_1.fulfillment_status = DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED
      @disburser_request_1.save!

      @disburser_request_3.status_user = @paul_user
      @disburser_request_3.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_3.save!

      @disburser_request_3.status_user = harold_user
      @disburser_request_3.fulfillment_status = DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED
      @disburser_request_3.save!

      @disburser_request_5.status_user = @paul_user
      @disburser_request_5.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_5.save!

      @disburser_request_5.status_user = harold_user
      @disburser_request_5.fulfillment_status = DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED
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
      @disburser_request_5.fulfillment_status = DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_INVENTORY_FULFILLED
      @disburser_request_5.save!

      visit specimen_coordinator_disburser_requests_path
      sleep(1)
      expect(all('.disburser_request').size).to eq(1)

      select('all', from: 'Fulfillment Status')
      click_button('Search')
      sleep(1)
      expect(all('.disburser_request').size).to eq(2)

      click_link('Fulfillment Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_5, 0)
      match_disburser_request_row(@disburser_request_3, 1)

      click_link('Fulfillment Status')
      sleep(1)
      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_5, 1)
    end
  end

  scenario 'Creating a disburser request', js: true, focus: false  do
    login_as(@moomintroll_user, scope: :user)
    visit disburser_requests_path

    expect(page).to have_selector('#new_repository_request_link', visible: false)
    select(@moomin_repository.name, from: 'Repository')
    expect(page).to have_selector('#new_repository_request_link', visible: true)
    select('Select a repository', from: 'Repository')
    expect(page).to have_selector('#new_repository_request_link', visible: false)
    select(@moomin_repository.name, from: 'Repository')
    click_link('Make a request!')
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
    fill_in('Cohort Criteria', with: disburser_request[:cohort_criteria])
    fill_in('Data for cohort', with: disburser_request[:data_for_cohort])

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

    choose('Submitted')
    click_button('Save')
    sleep(1)
    disburser_request[:status] = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
    match_disburser_request_row(disburser_request, 0)
    within('.disburser_request:nth-of-type(1)') do
      click_link('Edit')
    end

    expect(page.has_field?('Investigator', with: disburser_request[:investigator])).to be_truthy
    expect(page.has_field?('Title', with: disburser_request[:title])).to be_truthy
    expect(page.has_field?('IRB Number', with: disburser_request[:irb_number])).to be_truthy
    expect(page.has_checked_field?('Feasibility?')).to be_truthy
    expect(page).to have_css('a.methods_justifications_url', text: 'methods_justificatons.docx')
    expect(page.has_field?('Cohort Criteria', with: disburser_request[:cohort_criteria])).to be_truthy
    expect(page.has_field?('Data for cohort', with: disburser_request[:data_for_cohort])).to be_truthy


    expect(all('.disburser_request_detail')[0].find('.specimen_type select', text: disburser_request_detail[:specimen_type])).to be_truthy
    expect(all('.disburser_request_detail')[0].find_field('Quantity', with: disburser_request_detail[:quantity])).to be_truthy
    expect(all('.disburser_request_detail')[0].find_field('Volume', with: disburser_request_detail[:volume])).to be_truthy
    expect(all('.disburser_request_detail')[0].find_field('Comments', with: disburser_request_detail[:comments])).to be_truthy
  end

  scenario 'Creating a disburser request with validation', js: true, focus: false  do
    login_as(@moomintroll_user, scope: :user)
    visit disburser_requests_path
    select(@moomin_repository.name, from: 'Repository')
    click_link('Make a request!')
    expect(page).to have_css('.submitter', text: @moomintroll_user.full_name)

    within('.disburser_request_details') do
      click_link('Add')
    end

    disburser_request_detail = {}
    disburser_request_detail[:comments] = 'Moomin specimen'

    within(".disburser_request_detail:nth-of-type(1) .comments") do
      find('textarea').set(disburser_request_detail[:comments])
    end

    click_button('Save')

    within(".flash .callout") do
      expect(page).to have_content('Failed to create repository request.')
    end
    expect(page).to have_css('.investigator .field_with_errors')
    expect(page).to have_css('.title .field_with_errors')
    expect(page).to have_css('.irb_number .field_with_errors')
    expect(page).to have_css('.methods_justifications .field_with_errors')
    expect(page).to have_css('.cohort_criteria .field_with_errors')
    expect(page).to have_css('.data_for_cohort .field_with_errors')

    attach_file('Methods/Justifications', Rails.root + 'spec/fixtures/files/methods_justificatons.docx')

    click_button('Save')

    expect(page).to have_css('.investigator .field_with_errors')
    expect(page).to have_css('.title .field_with_errors')
    expect(page).to have_css('.irb_number .field_with_errors')
    expect(page).to have_css('a.methods_justifications_url', text: 'methods_justificatons.docx')
    expect(page).to have_css('.cohort_criteria .field_with_errors')
    expect(page).to have_css('.data_for_cohort .field_with_errors')
    expect(page).to have_css('.disburser_request_detail:nth-of-type(1) .specimen_type .field_with_errors')
    expect(page).to have_css('.disburser_request_detail:nth-of-type(1) .quantity .field_with_errors')
  end

  scenario 'Editing a disburser request', js: true, focus: false  do
    disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Moomin research', investigator: 'Sniff Moomin', irb_number: '123', cohort_criteria: 'Moomin cohort criteria.', data_for_cohort: 'Moomin data for cohort.', feasibility: true)
    disburser_request_detail = {}
    disburser_request_detail[:specimen_type] = @specimen_type_blood
    disburser_request_detail[:quantity] = '5'
    disburser_request_detail[:volume] = '10 mg'
    disburser_request_detail[:comments] = 'Moomin specimen'
    specimen_type = @moomin_repository.specimen_types.where(name: @specimen_type_blood).first
    disburser_request.disburser_request_details.build(specimen_type: specimen_type, quantity: disburser_request_detail[:quantity], volume: disburser_request_detail[:volume], comments: disburser_request_detail[:comments])
    disburser_request.save
    login_as(@moomintroll_user, scope: :user)
    visit disburser_requests_path

    all('.disburser_request')[0].find('.edit_disburser_request_link').click
    sleep(1)

    expect(page.has_field?('Investigator', with: disburser_request[:investigator])).to be_truthy
    expect(page.has_field?('Title', with: disburser_request[:title])).to be_truthy
    expect(page.has_field?('IRB Number', with: disburser_request[:irb_number])).to be_truthy
    expect(page.has_checked_field?('Feasibility?')).to be_truthy
    expect(page).to have_css('a.methods_justifications_url', text: 'methods_justificatons.docx')
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
    sleep(1)
    attach_file('Methods/Justifications', Rails.root + 'spec/fixtures/files/methods_justificatons2.docx')
    fill_in('Cohort Criteria', with: disburser_request[:cohort_criteria])
    fill_in('Data for cohort', with: disburser_request[:data_for_cohort])

    sleep(1)
    disburser_request_detail = {}
    disburser_request_detail[:specimen_type] = @specimen_type_tissue
    disburser_request_detail[:quantity] = '10'
    disburser_request_detail[:volume] = '20 mg'
    disburser_request_detail[:comments] = 'Moominmama specimen'

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

    click_button('Save')

    all('.disburser_request')[0].find('.edit_disburser_request_link').click
    sleep(1)

    expect(page.has_field?('Investigator', with: disburser_request[:investigator])).to be_truthy
    expect(page.has_field?('Title', with: disburser_request[:title])).to be_truthy
    expect(page.has_field?('IRB Number', with: disburser_request[:irb_number])).to be_truthy
    expect(page.has_unchecked_field?('Feasibility?')).to be_truthy
    expect(page).to have_css('a.methods_justifications_url', text: 'methods_justificatons2.docx')
    expect(page.has_field?('Cohort Criteria', with: disburser_request[:cohort_criteria])).to be_truthy
    expect(page.has_field?('Data for cohort', with: disburser_request[:data_for_cohort])).to be_truthy
    sleep(1)

    within(".disburser_request_detail:nth-of-type(1)") do
      click_link('Remove')
    end
    click_button('Save')
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

 scenario 'Editing a disburser request with validation', js: true, focus: false  do
   disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Moomin research', investigator: 'Sniff Moomin', irb_number: '123', cohort_criteria: 'Moomin cohort criteria.', data_for_cohort: 'Moomin data for cohort.', feasibility: false)
   disburser_request_detail = {}
   disburser_request_detail[:specimen_type] = @specimen_type_blood
   disburser_request_detail[:quantity] = '5'
   disburser_request_detail[:volume] = '10 mg'
   disburser_request_detail[:comments] = 'Moomin specimen'
   specimen_type = @moomin_repository.specimen_types.where(name: @specimen_type_blood).first
   disburser_request.disburser_request_details.build(specimen_type: specimen_type, quantity: disburser_request_detail[:quantity], volume: disburser_request_detail[:volume], comments: disburser_request_detail[:comments])
   disburser_request.save
   login_as(@moomintroll_user, scope: :user)
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

   click_button('Save')
   sleep(1)
   expect(page).to have_css('.investigator .field_with_errors')
   expect(page).to have_css('.title .field_with_errors')
   expect(page).to have_css('.irb_number .field_with_errors')
   expect(page).to have_css('.methods_justifications .field_with_errors')
   expect(page).to have_css('.cohort_criteria .field_with_errors')
   expect(page).to have_css('.data_for_cohort .field_with_errors')
   expect(page).to have_css('.disburser_request_detail:nth-of-type(1) .specimen_type .field_with_errors')
   expect(page).to have_css('.disburser_request_detail:nth-of-type(1) .quantity .field_with_errors')
   sleep(1)
   check('Feasibility?')
   click_button('Save')
   sleep(1)
   expect(page).to_not have_css('.irb_number .field_with_errors')
 end

 scenario 'Updating the status of a disburser request as a data coordinator', js: true, focus: false  do
   disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Moomin research', investigator: 'Sniff Moomin', irb_number: '123', cohort_criteria: 'Moomin cohort criteria.', data_for_cohort: 'Moomin data for cohort.', feasibility: true, status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @moomintroll_user)
   disburser_request_detail = {}
   disburser_request_detail[:specimen_type] = @specimen_type_blood
   disburser_request_detail[:quantity] = '5'
   disburser_request_detail[:volume] = '10 mg'
   disburser_request_detail[:comments] = 'Moomin specimen'
   specimen_type = @moomin_repository.specimen_types.where(name: @specimen_type_blood).first
   disburser_request.disburser_request_details.build(specimen_type: specimen_type, quantity: disburser_request_detail[:quantity], volume: disburser_request_detail[:volume], comments: disburser_request_detail[:comments])
   disburser_request.save
   disburser_request.reload
   expect(disburser_request.fulfillment_status).to eq(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_NOT_STARTED)
   harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
   allow(User).to receive(:find_ldap_entry_by_username).and_return(harold)
   @moomin_repository.repository_users.build(username: 'hbaines', administrator: false, data_coordinator: true)
   @moomin_repository.save!
   harold_user = User.where(username: 'hbaines').first
   login_as(harold_user, scope: :user)
   visit data_coordinator_disburser_requests_path

   expect(find("#disburser_request_#{disburser_request.id} .fulfillment_status")).to have_content(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_NOT_STARTED)

   find("#disburser_request_#{disburser_request.id}").click_link('Update Status')

   select('Select a fulfillment status', from: 'Fulfillment Status')
   click_button('Save')
   sleep(1)
   expect(page).to have_css('.status_update .field_with_errors')
   expect(find(".status_update .error")).to have_content("can't be blank")

   expect(page).to have_css('.submitter', text: @moomintroll_user.full_name)
   expect(page).to have_css('.investigator', text: disburser_request[:investigator])
   expect(page).to have_css('.title', text: disburser_request[:title])
   expect(page).to have_css('.irb_number', text: disburser_request[:irb_number])
   expect(page.has_checked_field?('Feasibility?', disabled: true)).to be_truthy
   expect(page).to have_css('a.methods_justifications_url', text: 'methods_justificatons.docx')
   expect(page.has_field?('Cohort Criteria', with: disburser_request[:cohort_criteria], disabled: true)).to be_truthy
   expect(page.has_field?('Data for cohort', with: disburser_request[:data_for_cohort], disabled: true)).to be_truthy

   disburser_request.disburser_request_details.each do |disburser_request_detail|
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .specimen_type")).to have_content(disburser_request_detail.specimen_type.name)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .quantity")).to have_content(disburser_request_detail.quantity)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .quantity")).to have_content(disburser_request_detail.quantity)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .volume")).to have_content(disburser_request_detail.volume)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .comments")).to have_content(disburser_request_detail.comments)
   end

   expect(all('.approval_stauses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS).each do |disburser_request_status|
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   expect(all('.fulfillment_statuses .disburser_request_status').size).to eq(0)

   select(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED, from: 'Fulfillment Status')
   comments = 'Help the moomins!'
   fill_in('Status Comments', with: comments)
   click_button('Save')
   sleep(1)
   expect(all('.disburser_request').size).to eq(0)
   select(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED, from: 'Fulfillment Status')
   click_button('Search')
   sleep(1)
   expect(all('.disburser_request').size).to eq(1)
   expect(find("#disburser_request_#{disburser_request.id} .fulfillment_status")).to have_content(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED)
   find("#disburser_request_#{disburser_request.id}").click_link('Update Status')
   sleep(1)

   expect(all('.approval_stauses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS).each do |disburser_request_status|
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   expect(all('.fulfillment_statuses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_FULLMILLMENT_STATUS).each do |disburser_request_status|
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end
 end

 scenario 'Updating the status of a disburser request as a specimen coordinator', js: true, focus: false  do
   disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Moomin research', investigator: 'Sniff Moomin', irb_number: '123', cohort_criteria: 'Moomin cohort criteria.', data_for_cohort: 'Moomin data for cohort.', feasibility: true, status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @moomintroll_user)
   disburser_request_detail = {}
   disburser_request_detail[:specimen_type] = @specimen_type_blood
   disburser_request_detail[:quantity] = '5'
   disburser_request_detail[:volume] = '10 mg'
   disburser_request_detail[:comments] = 'Moomin specimen'
   specimen_type = @moomin_repository.specimen_types.where(name: @specimen_type_blood).first
   disburser_request.disburser_request_details.build(specimen_type: specimen_type, quantity: disburser_request_detail[:quantity], volume: disburser_request_detail[:volume], comments: disburser_request_detail[:comments])
   disburser_request.save
   disburser_request.reload
   expect(disburser_request.fulfillment_status).to eq(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_NOT_STARTED)
   disburser_request.fulfillment_status = DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED
   disburser_request.status_user = @paul_user
   disburser_request.save!
   harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
   allow(User).to receive(:find_ldap_entry_by_username).and_return(harold)
   @moomin_repository.repository_users.build(username: 'hbaines', administrator: false, specimen_coordinator: true)
   @moomin_repository.save!
   harold_user = User.where(username: 'hbaines').first
   login_as(harold_user, scope: :user)
   visit specimen_coordinator_disburser_requests_path

   expect(find("#disburser_request_#{disburser_request.id} .fulfillment_status")).to have_content(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED)
   find("#disburser_request_#{disburser_request.id}").click_link('Update Status')
   select('Select a fulfillment status', from: 'Fulfillment Status')

   click_button('Save')
   sleep(1)
   expect(page).to have_css('.status_update .field_with_errors')
   expect(find(".status_update .error")).to have_content("can't be blank")

   expect(page).to have_css('.submitter', text: @moomintroll_user.full_name)
   expect(page).to have_css('.investigator', text: disburser_request[:investigator])
   expect(page).to have_css('.title', text: disburser_request[:title])
   expect(page).to have_css('.irb_number', text: disburser_request[:irb_number])
   expect(page.has_checked_field?('Feasibility?', disabled: true)).to be_truthy
   expect(page).to have_css('a.methods_justifications_url', text: 'methods_justificatons.docx')
   expect(page.has_field?('Cohort Criteria', with: disburser_request[:cohort_criteria], disabled: true)).to be_truthy
   expect(page.has_field?('Data for cohort', with: disburser_request[:data_for_cohort], disabled: true)).to be_truthy

   disburser_request.disburser_request_details.each do |disburser_request_detail|
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .specimen_type")).to have_content(disburser_request_detail.specimen_type.name)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .quantity")).to have_content(disburser_request_detail.quantity)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .quantity")).to have_content(disburser_request_detail.quantity)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .volume")).to have_content(disburser_request_detail.volume)
     expect(find("#disburser_request_detail_#{disburser_request_detail.id} .comments")).to have_content(disburser_request_detail.comments)
   end

   expect(all('.approval_stauses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS).each do |disburser_request_status|
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   expect(all('.fulfillment_statuses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_FULLMILLMENT_STATUS).each do |disburser_request_status|
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   select(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_INVENTORY_FULFILLED, from: 'Fulfillment Status')
   comments = 'Help the moomins!'
   fill_in('Status Comments', with: comments)
   click_button('Save')
   sleep(1)
   expect(all('.disburser_request').size).to eq(0)
   select(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_INVENTORY_FULFILLED, from: 'Fulfillment Status')
   click_button('Search')
   sleep(1)
   expect(all('.disburser_request').size).to eq(1)
   expect(find("#disburser_request_#{disburser_request.id} .fulfillment_status")).to have_content(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_INVENTORY_FULFILLED)
   find("#disburser_request_#{disburser_request.id}").click_link('Update Status')
   sleep(1)

   expect(all('.approval_stauses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS).each do |disburser_request_status|
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   expect(all('.fulfillment_statuses .disburser_request_status').size).to eq(2)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_FULLMILLMENT_STATUS).each do |disburser_request_status|
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end
 end

 scenario 'Updating the status of a disburser request as a repository administrator', js: true, focus: false  do
   disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Moomin research', investigator: 'Sniff Moomin', irb_number: '123', cohort_criteria: 'Moomin cohort criteria.', data_for_cohort: 'Moomin data for cohort.', feasibility: true, status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @moomintroll_user)
   disburser_request_detail = {}
   disburser_request_detail[:specimen_type] = @specimen_type_blood
   disburser_request_detail[:quantity] = '5'
   disburser_request_detail[:volume] = '10 mg'
   disburser_request_detail[:comments] = 'Moomin specimen'
   specimen_type = @moomin_repository.specimen_types.where(name: @specimen_type_blood).first
   disburser_request.disburser_request_details.build(specimen_type: specimen_type, quantity: disburser_request_detail[:quantity], volume: disburser_request_detail[:volume], comments: disburser_request_detail[:comments])
   disburser_request.save
   disburser_request.reload
   expect(disburser_request.fulfillment_status).to eq(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_NOT_STARTED)
   disburser_request.fulfillment_status = DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED
   disburser_request.status_user = @paul_user
   disburser_request.save!
   harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
   allow(User).to receive(:find_ldap_entry_by_username).and_return(harold)
   @moomin_repository.repository_users.build(username: 'hbaines', administrator: true)
   @moomin_repository.save!
   harold_user = User.where(username: 'hbaines').first
   login_as(harold_user, scope: :user)
   visit admin_disburser_requests_path

   expect(find("#disburser_request_#{disburser_request.id} .fulfillment_status")).to have_content(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED)

   find("#disburser_request_#{disburser_request.id}").click_link('Edit')
   select('Select an approval status', from: 'Approval Status')
   click_button('Save')
   sleep(1)
   expect(page).to have_css('.status_update .field_with_errors')
   expect(find(".status_update .error")).to have_content("can't be blank")

   expect(page.has_field?('Investigator', with: disburser_request[:investigator])).to be_truthy
   expect(page.has_field?('Title', with: disburser_request[:title])).to be_truthy
   expect(page.has_field?('IRB Number', with: disburser_request[:irb_number])).to be_truthy
   expect(page.has_checked_field?('Feasibility?')).to be_truthy
   expect(page).to have_css('a.methods_justifications_url', text: 'methods_justificatons.docx')
   expect(page.has_field?('Cohort Criteria', with: disburser_request[:cohort_criteria])).to be_truthy
   expect(page.has_field?('Data for cohort', with: disburser_request[:data_for_cohort])).to be_truthy

   disburser_request.disburser_request_details.each do |disburser_request_detail|
     expect(all("#disburser_request_detail_#{disburser_request_detail.id}")[0].find('.specimen_type select', text: disburser_request_detail[:specimen_type])).to be_truthy
     expect(all("#disburser_request_detail_#{disburser_request_detail.id}")[0].find_field('Quantity', with: disburser_request_detail[:quantity])).to be_truthy
     expect(all("#disburser_request_detail_#{disburser_request_detail.id}")[0].find_field('Volume', with: disburser_request_detail[:volume])).to be_truthy
     expect(all("#disburser_request_detail_#{disburser_request_detail.id}")[0].find_field('Comments', with: disburser_request_detail[:comments])).to be_truthy
   end

   expect(all('.approval_stauses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS).each do |disburser_request_status|
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   expect(all('.fulfillment_statuses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_FULLMILLMENT_STATUS).each do |disburser_request_status|
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   select(DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW, from: 'Approval Status')
   comments = 'Help the moomins!'
   fill_in('Status Comments', with: comments)
   click_button('Save')
   expect(find("#disburser_request_#{disburser_request.id} .status")).to have_content(DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW)
   find("#disburser_request_#{disburser_request.id}").click_link('Edit')
   sleep(1)

   expect(all('.approval_stauses .disburser_request_status').size).to eq(2)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS).each do |disburser_request_status|
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".approval_stauses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end

   expect(all('.fulfillment_statuses .disburser_request_status').size).to eq(1)

   disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_FULLMILLMENT_STATUS).each do |disburser_request_status|
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .status")).to have_content(disburser_request_status.status)
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .date")).to have_content(disburser_request_status.created_at.to_s(:date))
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .user")).to have_content(disburser_request_status.user.full_name)
     expect(find(".fulfillment_statuses #disburser_request_status_#{disburser_request_status.id} .comments")).to have_content(disburser_request_status.comments)
   end
 end
end

def match_disburser_request_row(disburser_request, index)
  expect(all('.disburser_request')[index].find('.title')).to have_content(disburser_request[:title])
  expect(all('.disburser_request')[index].find('.investigator')).to have_content(disburser_request[:investigator])
  expect(all('.disburser_request')[index].find('.irb_number')).to have_content(disburser_request[:irb_number])
  expect(all('.disburser_request')[index].find('.feasibility')).to have_content(human_boolean(disburser_request[:feasibility]))
  expect(all('.disburser_request')[index].find('.status')).to have_content(disburser_request[:status])
  expect(all('.disburser_request')[index].find('.fulfillment_status')).to have_content(disburser_request[:fulfillment_status])
end

def not_match_disburser_request(disburser_request)
  expect(page).to_not have_content(disburser_request[:title])
end
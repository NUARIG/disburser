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

  describe 'Seeing a list of disburser reqeusts' do
    before(:each) do
      @disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Groke research', investigator: 'Groke', irb_number: '123', cohort_criteria: 'Groke cohort criteria', data_for_cohort: 'Groke data for cohort')
      @disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Moomin research', investigator: 'Moominpapa', irb_number: '456', cohort_criteria: 'Momomin cohort criteria', data_for_cohort: 'Momomin data for cohort')
      @disburser_request_3 = FactoryGirl.create(:disburser_request, repository: @white_sox_repository, submitter: @paul_user, title: 'Sox baseball research', investigator: 'Nellie Fox', irb_number: '789', cohort_criteria: 'Sox cohort criteria', data_for_cohort: 'Sox data for cohort')
      @disburser_request_4 = FactoryGirl.create(:disburser_request, repository: @white_sox_repository, submitter: @moomintroll_user, title: 'White Sox research', investigator: 'Wilbur Wood', irb_number: '999', cohort_criteria: 'White Sox cohort criteria', data_for_cohort: 'White Sox data for cohort')
    end

    scenario 'As a regular user and sorting', js: true, focus: false do
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
    end

    scenario 'As a system administrator and sorting', js: true, focus: false do
      @moomintroll_user.system_administrator = true
      @moomintroll_user
      login_as(@moomintroll_user, scope: :user)
      visit root_path
      expect(page).to_not have_selector('.menu li.requests', visible: true)
      expect(page).to have_selector('.menu li.admin', visible: true)
      visit admin_disburser_requests_path

      expect(all('.disburser_request').size).to eq(4)

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
      sleep(1)
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
    end

    scenario 'As a repository administrator and sorting', js: true, focus: false do
      @disburser_request_5 = FactoryGirl.create(:disburser_request, repository: @white_sox_repository, submitter: @paul_user, title: 'White Sox z research', investigator: 'Wilbur Wood z', irb_number: '999', cohort_criteria: 'White Sox z cohort criteria', data_for_cohort: 'White Sox z data for cohort')
      @harold= { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com', administator: true,  committee: false, specimen_coordinator: false, data_coordinator: false }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold)
      @white_sox_repository.repository_users.build(username: 'hbaines', administrator: true)
      @white_sox_repository.save!
      @harold_user = User.where(username: 'hbaines').first

      login_as(@harold_user, scope: :user)
      visit root_path
      expect(page).to_not have_selector('.menu li.requests', visible: true)
      expect(page).to have_selector('.menu li.admin', visible: true)
      visit admin_disburser_requests_path
      expect(all('.disburser_request').size).to eq(3)

      match_disburser_request_row(@disburser_request_3, 0)
      match_disburser_request_row(@disburser_request_4, 1)
      match_disburser_request_row(@disburser_request_5, 2)
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
    match_disburser_request_row(disburser_request, 0, DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
    within('.disburser_request:nth-of-type(1)') do
      click_link('Edit')
    end

    expect(page.has_field?('Investigator', with: disburser_request[:investigator])).to be_truthy
    expect(page.has_field?('Title', with: disburser_request[:title])).to be_truthy
    expect(page.has_field?('IRB Number', with: disburser_request[:irb_number])).to be_truthy
    expect(page.has_checked_field?('Feasibility?')).to be_truthy
    expect(page).to have_css('a.methods_justifications_url', text: 'methods_justificatons.docx')
    expect(page.has_field?('Cohort Criteria', with: disburser_request[:cohort_criteria])).to be_truthy
    expect(page.has_field?('Data for cohort ', with: disburser_request[:data_for_cohort])).to be_truthy


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
    expect(page.has_field?('Data for cohort ', with: disburser_request[:data_for_cohort])).to be_truthy

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
    expect(page.has_field?('Data for cohort ', with: disburser_request[:data_for_cohort])).to be_truthy
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
 end
end

def match_disburser_request_row(disburser_request, index, status=DisburserRequest::DISBURSER_REQUEST_STAUTS_DRAFT)
  expect(all('.disburser_request')[index].find('.title')).to have_content(disburser_request[:title])
  expect(all('.disburser_request')[index].find('.investigator')).to have_content(disburser_request[:investigator])
  expect(all('.disburser_request')[index].find('.irb_number')).to have_content(disburser_request[:irb_number])
  expect(all('.disburser_request')[index].find('.status')).to have_content(status)
end

def not_match_disburser_request(disburser_request)
  expect(page).to_not have_content(disburser_request[:title])
end
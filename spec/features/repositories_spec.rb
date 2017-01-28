require 'rails_helper'
RSpec.feature 'Repositories', type: :feature do
  before(:each) do
    @moomin_repository = FactoryGirl.create(:repository, name: 'Moomins')
    @peanuts_repository = FactoryGirl.create(:repository, name: 'Peanuts')
    @repository_bossy_bear = FactoryGirl.create(:repository, name: 'Bossy Bear')
    @harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com', administator: true,  committee: false, specimen_coordinator: false, data_coordinator: false }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold)
    @moomin_repository.repository_users.build(username: 'hbaines', administrator: true)
    @moomin_repository.save!
    @peanuts_repository.repository_users.build(username: 'hbaines', administrator: true)
    @peanuts_repository.save!
    @harold_user = User.where(username: 'hbaines').first
    login_as(@harold_user, scope: :user)
    visit root_path
  end

  scenario 'Not seeing a list of Repositories', js: true, focus: false do
    @paul = { username: 'pkonerko', first_name: 'Paul', last_name: 'Konerko', email: 'pkonerko@whitesox.com', administator: false,  committee: false, specimen_coordinator: false, data_coordinator: false }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(@paul)
    @moomin_repository.repository_users.build(username: 'pkonerko', administrator: false, committee: true)
    @moomin_repository.save!
    @paul_user = User.where(username: 'pkonerko').first
    click_link('Log out')
    login_as(@paul_user, scope: :user)
    visit root_path
    sleep(1)
    expect(page).to_not have_css('.menu li.repositories')
  end

  scenario 'Visiting repositories and sorting', js: true, focus: false do
    click_link('Repositories')
    sleep(1)
    not_match_repository(@repository_bossy_bear)
    match_repository_row(@moomin_repository, 0)
    match_repository_row(@peanuts_repository, 1)

    click_link('Name')
    sleep(1)
    match_repository_row(@peanuts_repository, 0)
    match_repository_row(@moomin_repository, 1)

    click_link('Name')
    sleep(1)
    match_repository_row(@moomin_repository, 0)
    match_repository_row(@peanuts_repository, 1)
  end

  scenario 'Creating a repository', js: true, focus: false  do
    @harold_user.system_administrator = true
    @harold_user.save
    click_link('Repositories')
    click_link('New Repository')
    repository_rorty_institute = {}
    repository_rorty_institute[:name] = 'Rorty Institute'
    fill_in 'Name', with: repository_rorty_institute[:name]
    attach_file('IRB Template', Rails.root + 'spec/fixtures/files/moomins.docx')
    attach_file('Data Dictionary', Rails.root + 'spec/fixtures/files/peanuts.docx')
    click_button('Next')
    sleep(1)
    repository = Repository.where(name: repository_rorty_institute[:name]).first
    expect(current_path).to eq(edit_repository_path(repository))
    expect(page).to have_css('.menu li.repository.active')
    expect(page.has_field?('Name', with: repository_rorty_institute[:name])).to be_truthy
    expect(page).to have_css('a.irb_template_url', text: 'moomins.docx')
    expect(page).to have_css('a.data_dictionary_url', text: 'peanuts.docx')
    click_link('Users')
    sleep(1)
    expect(page).to have_css('.menu li.repository_users.active')
    click_link('Specimen Types')
    sleep(1)
    expect(page).to have_css('.menu li.specimen_types.active')
    click_link('Content')
    sleep(1)
    expect(page).to have_css('.menu li.repository_content.active')
  end

  scenario 'Creating a repository with validation', js: true, focus: false  do
    @harold_user.system_administrator = true
    @harold_user.save
    click_link('Repositories')
    click_link('New Repository')
    fill_in 'Name', with: nil
    attach_file('IRB Template', Rails.root + 'spec/fixtures/files/moomins.docx')
    attach_file('Data Dictionary', Rails.root + 'spec/fixtures/files/peanuts.docx')
    click_button('Next')

    expect(page).to have_css('a.irb_template_url', text: 'moomins.docx')
    expect(page).to have_css('a.data_dictionary_url', text: 'peanuts.docx')

    within(".flash .callout") do
      expect(page).to have_content('Failed to create repository.')
    end
    expect(page).to have_css('.name .field_with_errors')
    within(".name .error") do
      expect(page).to have_content("can't be blank")
    end

    attach_file('IRB Template', Rails.root + 'spec/fixtures/files/peanuts.docx')
    attach_file('Data Dictionary', Rails.root + 'spec/fixtures/files/moomins.docx')
    fill_in 'Name', with: 'Moomin Repository'
    click_button('Next')
    expect(page).to have_css('a.irb_template_url', text: 'peanuts.docx')
    expect(page).to have_css('a.data_dictionary_url', text: 'moomins.docx')
  end

  scenario 'Editing a repository', js: true, focus: false do
    click_link('Repositories')
    within(".repository:nth-of-type(1)") do
      click_link('Edit')
    end

    expect(page).to have_css('.menu li.repository.active')
    expect(page.has_field?('Name', with: @moomin_repository.name)).to be_truthy

    repository_moomin = {}
    repository_moomin[:name] = 'Moominss'
    fill_in 'Name', with: repository_moomin[:name]

    attach_file('IRB Template', Rails.root + 'spec/fixtures/files/moomins.docx')
    attach_file('Data Dictionary', Rails.root + 'spec/fixtures/files/peanuts.docx')

    click_button('Save')

    expect(page).to have_css('.menu li.repository.active')
    expect(page.has_field?('Name', with: repository_moomin[:name])).to be_truthy
    expect(page).to have_css('a.irb_template_url', text: 'moomins.docx')
    expect(page).to have_css('a.data_dictionary_url', text: 'peanuts.docx')

    within(".irb_template") do
      check('Remove file')
    end

    click_button('Save')

    expect(page).to_not have_css('a.irb_template_url', text: 'moomins.docx')

    within(".data_dictionary") do
      check('Remove file')
    end

    click_button('Save')
    expect(page).to_not have_css('a.data_dictionary_url', text: 'peanuts.docx')

    visit repositories_path
    match_repository_row(repository_moomin, 0)

    within(".repository:nth-of-type(1)") do
      click_link('Edit')
    end

    click_link('Content')
    expect(page).to have_css('.menu li.repository_content.active')
    fill_in_ckeditor 'repository_general_content', :with => 'Be a a good person!'
    fill_in_ckeditor 'repository_data_content', :with => 'Be a good moomin!'
    fill_in_ckeditor 'repository_specimen_content', :with => 'Be a really good moomin!'
    click_button('Save')
    sleep(2)
    expect(page).to have_css('.menu li.repository_content.active')
    expect(read_ckeditor('repository_general_content')).to eq("<p>Be a a good person!</p>\n")
    expect(read_ckeditor('repository_data_content')).to eq("<p>Be a good moomin!</p>\n")
    expect(read_ckeditor('repository_specimen_content')).to eq("<p>Be a really good moomin!</p>\n")

    click_link('Users')
    expect(page).to have_css('.menu li.repository_users.active')
    moomins = [{ username: 'moominpapa', first_name: 'Moominpapa', last_name: 'Moomin', email: 'moominpapa@moomin.com' }, { username: 'moominmamma', first_name: 'Moominmamma', last_name: 'Moomin', email: 'moominmamma@moomin.com' }]
    moominpapa = [{ username: 'moominpapa', first_name: 'Moominpapa', last_name: 'Moomin', email: 'moominpapa@moomin.com' }]
    allow(User).to receive(:find_ldap_entries_by_name).with('moomin').and_return(moomins)
    allow(User).to receive(:find_ldap_entries_by_name).with('moominpapa').and_return(moominpapa)
    click_link('New User')
    page.find('.select2-selection ').native.send_keys(:return)
    find('.select2-dropdown input').set('moomin')
    find(".select2-results__option", text: 'Moominmamma').click
    expect(find(".select2-selection__rendered", text: 'Moominmamma Moomin')).to be_truthy
    check('Administrator?')
    check('Committee Member?')
    check('Specimen Coordinator?')
    check('Data Coordinator?')
    moominmama = { username: 'moominmamma', first_name: 'Moominmamma', last_name: 'Moomin', email: 'moominmamma@moomin.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(moominmama)
    click_button('Save')
    sleep(1)
    repository_user = moominmama
    repository_user[:administrator] = true
    repository_user[:committee] = true
    repository_user[:specimen_coordinator] = true
    repository_user[:data_coordinator] = true
    match_repository_user_row(@harold_user, 0)
    match_repository_user_row(repository_user, 1)

    repository_user = @moomin_repository.repository_users.joins(:user).where('users.username = ?', repository_user[:username]).first
    within("#repository_user_#{repository_user.id}") do
      click_link('Edit')
    end

    expect(page).to have_css('.username', text: repository_user[:username])
    expect(page).to have_css('.first_name', text: repository_user[:first_name])
    expect(page).to have_css('.last_name', text: repository_user[:last_name])
    expect(page).to have_css('.email', text: repository_user[:email])
    expect(page.has_checked_field?('Administrator?')).to be_truthy
    expect(page.has_checked_field?('Committee Member?')).to be_truthy
    expect(page.has_checked_field?('Specimen Coordinator?')).to be_truthy
    expect(page.has_checked_field?('Data Coordinator?')).to be_truthy
    uncheck('Administrator?')
    uncheck('Committee Member?')
    uncheck('Specimen Coordinator?')
    uncheck('Data Coordinator?')
    repository_user[:administrator] = false
    repository_user[:committee] = false
    repository_user[:specimen_coordinator] = false
    repository_user[:data_coordinator] = false
    click_button('Save')
    sleep(1)
    match_repository_user_row(repository_user, 1)
    click_link('Specimen Types')
    expect(page).to have_css('.menu li.specimen_types.active')
    sleep(1)
    click_link('Add')

    within(".specimen_type:nth-of-type(1) .name") do
      find('input').set 'Moomin'
    end

    click_link('Add')

    within(".specimen_type:nth-of-type(2) .name") do
      find('input').set 'Little My'
    end

    click_button('Save')

    within(".specimen_type:nth-of-type(1) .name") do
      expect(find('input').value).to eq('Little My')
    end

    within(".specimen_type:nth-of-type(2) .name") do
      expect(find('input').value).to eq('Moomin')
    end
  end

  scenario 'Editing a repository with validation', js: true, focus: false do
    click_link('Repositories')
    within(".repository:nth-of-type(1)") do
      click_link('Edit')
    end

    fill_in 'Name', with: nil
    click_button('Save')

    within(".flash .callout") do
      expect(page).to have_content('Failed to update repository.')
    end
    expect(page).to have_css('.name .field_with_errors')

    within(".name .error") do
      expect(page).to have_content("can't be blank")
    end

    attach_file('IRB Template', Rails.root + 'spec/fixtures/files/moomins.docx')
    attach_file('Data Dictionary', Rails.root + 'spec/fixtures/files/peanuts.docx')
    click_button('Save')

    expect(page).to have_css('a.irb_template_url', text: 'moomins.docx')
    expect(page).to have_css('a.data_dictionary_url', text: 'peanuts.docx')

    fill_in 'Name', with: 'Preanuts Repository'
    click_button('Save')

    expect(page).to have_css('a.irb_template_url', text: 'moomins.docx')
    expect(page).to have_css('a.data_dictionary_url', text: 'peanuts.docx')

    expect(page.has_field?('Name', with: 'Preanuts Repository')).to be_truthy

    click_link('Users')
    expect(page).to have_css('.menu li.repository_users.active')

    click_link('New User')
    click_button('Save')

    expect(page).to have_css('.username .field_with_errors')
    within(".username .error") do
      expect(page).to have_content("can't be blank")
    end

    moomins = [{ username: 'moominpapa', first_name: 'Moominpapa', last_name: 'Moomin', email: 'moominpapa@moomin.com' }, { username: 'moominmamma', first_name: 'Moominmamma', last_name: 'Moomin', email: 'moominmamma@moomin.com' }]
    moominpapa = [{ username: 'moominpapa', first_name: 'Moominpapa', last_name: 'Moomin', email: 'moominpapa@moomin.com' }]
    allow(User).to receive(:find_ldap_entries_by_name).with('moomin').and_return(moomins)
    allow(User).to receive(:find_ldap_entries_by_name).with('moominpapa').and_return(moominpapa)

    page.find('.select2-selection ').native.send_keys(:return)
    find('.select2-dropdown input').set('moomin')
    find(".select2-results__option", text: 'Moominmamma').click
    expect(find(".select2-selection__rendered", text: 'Moominmamma Moomin')).to be_truthy

    click_link('Cancel')

    click_link('Specimen Types')
    expect(page).to have_css('.menu li.specimen_types.active')
    sleep(1)
    click_link('Add')
    click_button('Save')

    expect(page).to have_css('.specimen_type:nth-of-type(1) .name .field_with_errors')

    within(".specimen_type:nth-of-type(1) .name .error") do
      expect(page).to have_content("can't be blank")
    end
  end

  scenario 'Editing a repository and preventing the deletion of a specimen type with dependent disburser request details', js: true, focus: false do
    specimen_type = FactoryGirl.create(:specimen_type, repository: @moomin_repository, name: 'Blood')
    click_link('Repositories')
    sleep(1)
    all("#repository_#{@moomin_repository.id}")[0].find_link('Edit').click
    click_link('Specimen Types')
    sleep(1)
    expect(page).to_not have_selector(".specimen_type a.disabled[href='']")
    disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @harold_user)
    disburser_request.disburser_request_details.build(specimen_type: specimen_type, quantity: 1)
    disburser_request.save
    click_link('Specimen Types')
    sleep(1)
    expect(page).to have_selector(".specimen_type a.disabled[href='']")
  end
end

def match_repository_row(repository, index)
  expect(all('.repository')[index].find('.name')).to have_content(repository[:name])
end

def not_match_repository(repository)
  expect(page).to_not have_content(repository[:name])
end

def match_repository_user_row(repository_user, index)
  expect(all('.repository_user')[index].find('.username')).to have_content(repository_user[:username])
  expect(all('.repository_user')[index].find('.first_name')).to have_content(repository_user[:first_name])
  expect(all('.repository_user')[index].find('.last_name')).to have_content(repository_user[:last_name])
  expect(all('.repository_user')[index].find('.email')).to have_content(repository_user[:email])
  expect(all('.repository_user')[index].find('.administrator')).to have_content(repository_user[:administrator])
  expect(all('.repository_user')[index].find('.committee')).to have_content(repository_user[:committee])
  expect(all('.repository_user')[index].find('.specimen_coordinator')).to have_content(repository_user[:specimen_coordinator])
  expect(all('.repository_user')[index].find('.data_coordinator')).to have_content(repository_user[:data_coordinator])
end

def fill_in_ckeditor(locator, opts)
  content = opts.fetch(:with).to_json
  page.execute_script <<-SCRIPT
    CKEDITOR.instances['#{locator}'].setData(#{content});
    $('textarea##{locator}').text(#{content});
  SCRIPT
end

def read_ckeditor(locator)
  page.evaluate_script <<-SCRIPT
    CKEDITOR.instances['#{locator}'].getData();
  SCRIPT
end
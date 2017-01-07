require 'rails_helper'
RSpec.feature 'Repositories', type: :feature do
  before(:each) do
    @repository_moomin = FactoryGirl.create(:repository, name: 'Moomins', data: true, specimens: false)
    @repository_peanuts = FactoryGirl.create(:repository, name: 'Peanuts', data: false, specimens: true)
    @repository_bossy_bear = FactoryGirl.create(:repository, name: 'Bossy Bear', data: false, specimens: true)
    @harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com', administator: true,  committee: false, specimen_resource: false, data_resource: false }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold)
    @repository_moomin.repository_users.build(username: 'hbaines', administrator: true)
    @repository_moomin.save!
    @repository_peanuts.repository_users.build(username: 'hbaines', administrator: true)
    @repository_peanuts.save!
    @harold_user = User.where(username: 'hbaines').first
    login_as(@harold_user, scope: :user)
    visit root_path
  end

  scenario 'Not seeing a list of my repositories', js: true, focus: false do
    @paul = { username: 'pkonerko', first_name: 'Paul', last_name: 'Konerko', email: 'pkonerko@whitesox.com', administator: false,  committee: false, specimen_resource: false, data_resource: false }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(@paul)
    @repository_moomin.repository_users.build(username: 'hbaines', administrator: false, committee: true)
    @repository_moomin.save!
    @paul_user = User.where(username: 'pkonerko').first
    click_link('Log out')
    login_as(@paul_user, scope: :user)
    visit root_path
    expect(page).to_not have_css('.menu li.my_repositories')
  end

  scenario 'Visiting repositories and sorting', js: true, focus: false do
    click_link('My Repositories')
    not_match_repository(@repository_bossy_bear)
    match_repository_row(@repository_moomin, 0)
    match_repository_row(@repository_peanuts, 1)

    click_link('Name')
    sleep(1)
    match_repository_row(@repository_peanuts, 0)
    match_repository_row(@repository_moomin, 1)

    click_link('Name')
    sleep(1)
    match_repository_row(@repository_moomin, 0)
    match_repository_row(@repository_peanuts, 1)

    click_link('Data')
    sleep(1)
    match_repository_row(@repository_peanuts, 0)
    match_repository_row(@repository_moomin, 1)

    click_link('Data')
    sleep(1)
    match_repository_row(@repository_moomin, 0)
    match_repository_row(@repository_peanuts, 1)

    click_link('Specimens')
    sleep(1)
    match_repository_row(@repository_moomin, 0)
    match_repository_row(@repository_peanuts, 1)

    click_link('Specimens')
    sleep(1)
    match_repository_row(@repository_peanuts, 0)
    match_repository_row(@repository_moomin, 1)
  end

  scenario 'Creating a repository', js: true, focus: false  do
    @harold_user.system_administrator = true
    @harold_user.save
    click_link('My Repositories')
    click_link('New Repository')
    repository_rorty_institute = {}
    repository_rorty_institute[:name] = 'Rorty Institute'
    repository_rorty_institute[:data] = true
    repository_rorty_institute[:specimens] = true
    fill_in 'Name', with: repository_rorty_institute[:name]
    check('Data?')
    check('Specimens?')
    attach_file('IRB Template', Rails.root + 'spec/fixtures/files/moomins.docx')
    attach_file('Data Dictionary', Rails.root + 'spec/fixtures/files/peanuts.docx')
    click_button('Next')
    repository = Repository.where(name: repository_rorty_institute[:name]).first
    expect(current_path).to eq(edit_repository_path(repository))
    expect(page).to have_css('.menu li.repository.active')
    expect(page.has_field?('Name', with: repository_rorty_institute[:name])).to be_truthy
    expect(page.has_checked_field?('Data?')).to be_truthy
    expect(page.has_checked_field?('Specimens?')).to be_truthy
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
    click_link('My Repositories')
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
    click_link('My Repositories')
    within(".repository:nth-of-type(1)") do
      click_link('Edit')
    end

    expect(page).to have_css('.menu li.repository.active')
    expect(page.has_field?('Name', with: @repository_moomin.name)).to be_truthy
    expect(page.has_checked_field?('Data?')).to be_truthy
    expect(page.has_unchecked_field?('Specimens?')).to be_truthy

    repository_moomin = {}
    repository_moomin[:name] = 'Moominss'
    repository_moomin[:data] = false
    repository_moomin[:specimens] = true

    fill_in 'Name', with: repository_moomin[:name]
    uncheck('Data')
    check('Specimens')

    attach_file('IRB Template', Rails.root + 'spec/fixtures/files/moomins.docx')
    attach_file('Data Dictionary', Rails.root + 'spec/fixtures/files/peanuts.docx')

    click_button('Save')

    expect(page).to have_css('.menu li.repository.active')
    expect(page.has_field?('Name', with: repository_moomin[:name])).to be_truthy
    expect(page.has_unchecked_field?('Data?')).to be_truthy
    expect(page.has_checked_field?('Specimens?')).to be_truthy
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
    fill_in_ckeditor 'repository_data_content', :with => 'Be a good moomin!'
    fill_in_ckeditor 'repository_specimen_content', :with => 'Be a really good moomin!'
    click_button('Save')
    expect(page).to have_css('.menu li.repository_content.active')
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
    check('Specimen Resource?')
    check('Data Resource?')
    moominmama = { username: 'moominmamma', first_name: 'Moominmamma', last_name: 'Moomin', email: 'moominmamma@moomin.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(moominmama)
    click_button('Save')
    sleep(1)
    repository_user = moominmama
    repository_user[:administrator] = true
    repository_user[:committee] = true
    repository_user[:specimen_resource] = true
    repository_user[:data_resource] = true
    match_repository_user_row(@harold_user, 0)
    match_repository_user_row(repository_user, 1)

    repository_user = @repository_moomin.repository_users.joins(:user).where('users.username = ?', repository_user[:username]).first
    within("#repository_user_#{repository_user.id}") do
      click_link('Edit')
    end

    expect(page).to have_css('.username', text: repository_user[:username])
    expect(page).to have_css('.first_name', text: repository_user[:first_name])
    expect(page).to have_css('.last_name', text: repository_user[:last_name])
    expect(page).to have_css('.email', text: repository_user[:email])
    expect(page.has_checked_field?('Administrator?')).to be_truthy
    expect(page.has_checked_field?('Committee Member?')).to be_truthy
    expect(page.has_checked_field?('Specimen Resource?')).to be_truthy
    expect(page.has_checked_field?('Data Resource?')).to be_truthy
    uncheck('Administrator?')
    uncheck('Committee Member?')
    uncheck('Specimen Resource?')
    uncheck('Data Resource?')
    repository_user[:administrator] = false
    repository_user[:committee] = false
    repository_user[:specimen_resource] = false
    repository_user[:data_resource] = false
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

    within(".specimen_type:nth-of-type(1) .volume") do
      find("input[type='checkbox']").set(true)
    end

    click_link('Add')

    within(".specimen_type:nth-of-type(2) .name") do
      find('input').set 'Little My'
    end

    within(".specimen_type:nth-of-type(2) .volume") do
      find("input[type='checkbox']").set(false)
    end

    click_button('Save')

    within(".specimen_type:nth-of-type(1) .name") do
      expect(find('input').value).to eq('Little My')
    end

    within(".specimen_type:nth-of-type(1) .volume") do
      expect(find("input[type='checkbox']").checked?).to be_falsy
    end

    within(".specimen_type:nth-of-type(2) .name") do
      expect(find('input').value).to eq('Moomin')
    end

    within(".specimen_type:nth-of-type(2) .volume") do
      expect(find("input[type='checkbox']").checked?).to be_truthy
    end
  end

  scenario 'Editing a repository with validation', js: true, focus: false do
    click_link('My Repositories')
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
end

def match_repository_row(repository, index)
  expect(all('.repository')[index].find('.name')).to have_content(repository[:name])
  expect(all('.repository')[index].find('.data')).to have_content(repository[:data])
  expect(all('.repository')[index].find('.specimens')).to have_content(repository[:specimens])
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
  expect(all('.repository_user')[index].find('.specimen_resource')).to have_content(repository_user[:specimen_resource])
  expect(all('.repository_user')[index].find('.data_resource')).to have_content(repository_user[:data_resource])
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
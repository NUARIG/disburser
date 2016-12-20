require 'rails_helper'
RSpec.feature 'Repositories', type: :feature do
  before(:each) do
    @repository_moomin = FactoryGirl.create(:repository, name: 'Moomins', data: true, specimens: false)
    @repository_peanuts = FactoryGirl.create(:repository, name: 'Peanuts', data: false, specimens: true)
    @moomin_user = FactoryGirl.create(:user, email: 'moomin@momin.com', password: 'password', username: 'moomin')
    login_as(@moomin_user, scope: :user)
    visit repositories_path
  end

  scenario 'Visiting repositories and sorting', js: true, focus: false do
    match_repository_row(@repository_moomin, 1)
    match_repository_row(@repository_peanuts, 2)

    click_link('Name')

    match_repository_row(@repository_peanuts, 1)
    match_repository_row(@repository_moomin, 2)

    click_link('Name')

    match_repository_row(@repository_moomin, 1)
    match_repository_row(@repository_peanuts, 2)

    click_link('Data')

    match_repository_row(@repository_peanuts, 1)
    match_repository_row(@repository_moomin, 2)

    click_link('Data')

    match_repository_row(@repository_moomin, 1)
    match_repository_row(@repository_peanuts, 2)

    click_link('Specimens')

    match_repository_row(@repository_moomin, 1)
    match_repository_row(@repository_peanuts, 2)

    click_link('Specimens')

    match_repository_row(@repository_peanuts, 1)
    match_repository_row(@repository_moomin, 2)
  end

  scenario 'Creating a repository', js: true, focus: false  do
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
    expect(page).to have_css('.menu li.users.active')
    click_link('Specimen Types')
    expect(page).to have_css('.menu li.specimen_types.active')
  end

  scenario 'Creating a repository with validation', js: true, focus: false  do
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
    match_repository_row(repository_moomin, 1)

    within(".repository:nth-of-type(1)") do
      click_link('Edit')
    end

    click_link('Users')
    expect(page).to have_css('.menu li.users.active')
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
    repository_user = moominmama
    repository_user[:administrator] = true
    repository_user[:committee] = true
    repository_user[:specimen_resource] = true
    repository_user[:data_resource] = true
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

  scenario 'Editing a repository with validation', js: true, focus: true do
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
    expect(page).to have_css('.menu li.users.active')

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
  within(".repository:nth-of-type(#{index}) .name") do
    expect(page).to have_content(repository[:name])
  end

  within(".repository:nth-of-type(#{index}) .data") do
    expect(page).to have_content(repository[:data].to_s)
  end

  within(".repository:nth-of-type(#{index}) .specimens") do
    expect(page).to have_content(repository[:specimens].to_s)
  end
end

def match_repository_user_row(repository_user, index)
  within(".repository_user:nth-of-type(#{index}) .username") do
    expect(page).to have_content(repository_user[:username])
  end

  within(".repository_user:nth-of-type(#{index}) .first_name") do
    expect(page).to have_content(repository_user[:first_name])
  end

  within(".repository_user:nth-of-type(#{index}) .last_name") do
    expect(page).to have_content(repository_user[:last_name])
  end

  within(".repository_user:nth-of-type(#{index}) .email") do
    expect(page).to have_content(repository_user[:email])
  end

  within(".repository_user:nth-of-type(#{index}) .administrator") do
    expect(page).to have_content(repository_user[:administrator].to_s)
  end

  within(".repository_user:nth-of-type(#{index}) .committee") do
    expect(page).to have_content(repository_user[:committee].to_s)
  end

  within(".repository_user:nth-of-type(#{index}) .specimen_resource") do
    expect(page).to have_content(repository_user[:specimen_resource].to_s)
  end

  within(".repository_user:nth-of-type(#{index}) .data_resource") do
    expect(page).to have_content(repository_user[:data_resource].to_s)
  end
end
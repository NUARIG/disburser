require 'rails_helper'
RSpec.feature 'Repositories', type: :feature do
  before(:each) do
    @repository_moomin = FactoryGirl.create(:repository, name: 'Moomins', data: true, specimens: false)
    @repository_peanuts = FactoryGirl.create(:repository, name: 'Peanuts', data: false, specimens: true)

    visit repositories_path
  end

  scenario 'Visiting repositories and sorting', js: true, focus: false do
    match_row(@repository_moomin, 1)
    match_row(@repository_peanuts, 2)

    click_link('Name')

    match_row(@repository_peanuts, 1)
    match_row(@repository_moomin, 2)

    click_link('Name')

    match_row(@repository_moomin, 1)
    match_row(@repository_peanuts, 2)

    click_link('Data')

    match_row(@repository_peanuts, 1)
    match_row(@repository_moomin, 2)

    click_link('Data')

    match_row(@repository_moomin, 1)
    match_row(@repository_peanuts, 2)

    click_link('Specimens')

    match_row(@repository_moomin, 1)
    match_row(@repository_peanuts, 2)

    click_link('Specimens')

    match_row(@repository_peanuts, 1)
    match_row(@repository_moomin, 2)
  end

  scenario 'Creating a repository', js: true, focus: false  do
    click_link('New Repository')
    repository_rorty_institute = {}
    repository_rorty_institute[:name] = 'Rorty Institute'
    repository_rorty_institute[:data] = true
    repository_rorty_institute[:specimens] = true
    fill_in 'Name', with: repository_rorty_institute[:name]
    check('Title')
    check('Specimens')
    click_button('Save')

    match_row(repository_rorty_institute, 3)
  end

  scenario 'Creating a repository with validation', js: true, focus: false  do
    click_link('New Repository')
    fill_in 'Name', with: nil
    click_button('Save')

    within(".flash .callout") do
      expect(page).to have_content('Failed to create repository.')
    end
    expect(page).to have_css('.name .field_with_errors')
    within(".name .error") do
      expect(page).to have_content("can't be blank")
    end
  end

  scenario 'Editing a repository', js: true, focus: false do
    within(".repository:nth-of-type(1)") do
      click_link('Edit')
    end
    expect(find_field('Name').value).to eq 'Moomins'
    expect(find_field('Data', checked: true)).to be_truthy
    expect(find_field('Specimens', checked: false)).to be_truthy

    repository_moomin = {}
    repository_moomin[:name] = 'Moominss'
    repository_moomin[:data] = false
    repository_moomin[:specimens] = false

    fill_in 'Name', with: repository_moomin[:name]
    uncheck('Data')
    uncheck('Specimens')
    click_button('Save')

    match_row(repository_moomin, 1)
  end

  scenario 'Editing a repository with validation', js: true, focus: false do
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
  end
end

def match_row(repository, index)
  within(".repository:nth-of-type(#{index}) .name") do
    expect(page).to have_content(repository[:name])
  end

  within(".repository:nth-of-type(#{index}) .data") do
    expect(page).to have_content(repository[:data])
  end

  within(".repository:nth-of-type(#{index}) .specimens") do
    expect(page).to have_content(repository[:specimens])
  end
end
require 'rails_helper'
RSpec.feature 'Repositories', type: :feature do
  before(:each) do
    @repository_moomin_specimen_content = '<b>Moomins collect specimens</b>'
    @repository_moomin_data_content = '<b>Moomins collect data</b>'
    @repository_moomin = FactoryGirl.create(:repository, name: 'Moomins', data: true, specimens: false, data_content: @repository_moomin_data_content, specimen_content: @repository_moomin_specimen_content)
    @repository_peanuts = FactoryGirl.create(:repository, name: 'Peanuts', data: false, specimens: true, data_content: '<b>Peanuts collect data</b>', specimen_content: '<b>Peanuts collect specimens</b>')
    visit root_path
  end

  scenario 'Visiting home repositories and sorting', js: true, focus: false do
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

  scenario 'Visting a repository ', js: true, focus: false do
    within("#repository_#{@repository_moomin.id}") do
      click_link('View')
    end
    expect(page).to have_css('.data_content b', text: 'Moomins collect data')
    expect(page).to have_css('.specimen_content b', text: 'Moomins collect specimens')
  end
end
require 'rails_helper'
RSpec.feature 'Repositories', type: :feature do
  before(:each) do
    @repository_moomin_general_content = '<b>Some general Moomin information.</b>'
    @repository_moomin_specimen_content = '<b>Moomins collect specimens.</b>'
    @repository_moomin_data_content = '<b>Moomins collect data.</b>'
    @repository_moomin = FactoryGirl.create(:repository, name: 'Moomins', public: true, general_content: @repository_moomin_general_content, data_content: @repository_moomin_data_content, specimen_content: @repository_moomin_specimen_content, data_dictionary: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/data_dictionary.docx'))),irb_template: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/irb_template.docx'))), custom_request_form: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/custom_request_form.docx'))))
    @repository_peanuts = FactoryGirl.create(:repository, name: 'Peanuts', public: true, general_content: '<b>Some general Peanuts information.</b>', data_content: '<b>Peanuts collect data</b>', specimen_content: '<b>Peanuts collect specimens</b>')
    @repository_white_sox = FactoryGirl.create(:repository, name: 'White Sox', public: false, general_content: '<b>Some general White Sox information.</b>', data_content: '<b>White Sox collect data</b>', specimen_content: '<b>Peanuts collect specimens</b>')
    visit root_path
    scroll_to_bottom_of_the_page
    sleep(2)
  end

  scenario 'Visiting home repositories and sorting', js: true, focus: false do
    expect(all('.repository').size).to eq(2)
    match_repository_row(@repository_moomin, 0)
    match_repository_row(@repository_peanuts, 1)

    click_link('Name')
    sleep(2)
    scroll_to_bottom_of_the_page
    match_repository_row(@repository_peanuts, 0)
    match_repository_row(@repository_moomin, 1)

    click_link('Name')
    sleep(2)
    scroll_to_bottom_of_the_page
    match_repository_row(@repository_moomin, 0)
    match_repository_row(@repository_peanuts, 1)
  end

  scenario 'Visting a repository ', js: true, focus: false do
    scroll_to_bottom_of_the_page
    within("#repository_#{@repository_moomin.id}") do
      click_link('View')
    end
    expect(page).to have_css('.general_content b', text: 'Some general Moomin information.')
    expect(page).to have_css('.data_content b', text: 'Moomins collect data.')
    expect(page).to have_css('.specimen_content b', text: 'Moomins collect specimens.')
    expect(page).to have_css('a.irb_template_url', text: 'irb_template.docx')
    expect(page).to have_css('a.data_dictionary_url', text: 'data_dictionary.docx')
    expect(page).to have_css('a.custom_request_form_url', text: 'custom_request_form.docx')
  end
end
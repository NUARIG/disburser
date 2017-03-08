require 'rails_helper'
RSpec.feature 'Users', type: :feature do
  before(:each) do
    @repository_moomin = FactoryGirl.create(:repository, name: 'Moomins')
    @harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com', administator: true,  committee: false, specimen_coordinator: false, data_coordinator: false }
    allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
    @repository_moomin.repository_users.build(username: 'hbaines', administrator: true)
    @repository_moomin.save!
    @harold_user = NorthwesternUser.where(username: 'hbaines').first
    login_as(@harold_user, scope: :northwestern_user)
    visit root_path
  end

  scenario 'Visiting profile page', js: true, focus: false do
    click_link("Profile (#{@harold_user.username})")
    expect(page).to have_css('.username', text: @harold_user.username)
    expect(page).to have_css('.first_name', text: @harold_user.first_name)
    expect(page).to have_css('.last_name', text: @harold_user.last_name)
    expect(page).to have_css('.email', text: @harold_user.email)
  end
end
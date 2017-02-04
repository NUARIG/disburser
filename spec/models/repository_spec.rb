require 'rails_helper'
require 'active_support'

RSpec.describe Repository, type: :model do
  it { should have_many :repository_users }
  it { should have_many :specimen_types }
  it { should have_many :users }
  it { should have_many :disburser_requests }
  it { should validate_presence_of :name }

  it 'can search accross fields (by name)', focus: false do
    repository_1 = FactoryGirl.create(:repository, name: 'Moomins')
    repository_2 = FactoryGirl.create(:repository, name: 'Peanuts')
    expect(Repository.search_across_fields('Moomin')).to match_array([repository_1])
  end

  it 'can search accross fields (by accession number) case insensitively', focus: false do
    repository_1 = FactoryGirl.create(:repository, name: 'Moomins')
    repository_2 = FactoryGirl.create(:repository, name: 'Peanuts')
    expect(Repository.search_across_fields('MOOMIN')).to match_array([repository_1])
  end

  it 'can search accross fields (and sort ascending/descending by a passed in column)', focus: false do
    repository_1 = FactoryGirl.create(:repository, name: 'Moomins')
    repository_2 = FactoryGirl.create(:repository, name: 'Peanuts')
    expect(Repository.search_across_fields(nil, { sort_column: 'name', sort_direction: 'asc' })).to eq([repository_1, repository_2])
    expect(Repository.search_across_fields(nil, { sort_column: 'name', sort_direction: 'desc' })).to eq([repository_2, repository_1])
  end

  it 'knows if a user is a repository administrator', focus: false do
    harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(harold_user)
    repository = FactoryGirl.create(:repository, name: 'Moomins')
    repository.repository_users.build(username: 'hbaines', administrator: true)
    repository.save!
    harold_user = User.where(username: 'hbaines').first
    expect(repository.repository_administrator?(harold_user)).to be_truthy
  end

  it 'knows if a user is not a repository administrator', focus: false do
    moomintroll_user = FactoryGirl.create(:user, email: 'moomintroll@moomin.com', username: 'moomintroll', first_name: 'Moomintroll', last_name: 'Moomin')
    moomintroll_user = User.where(username: 'moomintroll').first
    repository = FactoryGirl.create(:repository, name: 'Moomins')
    expect(repository.repository_administrator?(moomintroll_user)).to be_falsy
  end

  it 'knows if a user is a repository committee member', focus: false do
    harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(harold_user)
    repository = FactoryGirl.create(:repository, name: 'Moomins')
    repository.repository_users.build(username: 'hbaines', committee: true)
    repository.save!
    harold_user = User.where(username: 'hbaines').first
    expect(repository.committee_member?(harold_user)).to be_truthy
  end

  it 'knows if a user is not a repository committee member', focus: false do
    moomintroll_user = FactoryGirl.create(:user, email: 'moomintroll@moomin.com', username: 'moomintroll', first_name: 'Moomintroll', last_name: 'Moomin')
    moomintroll_user = User.where(username: 'moomintroll').first
    repository = FactoryGirl.create(:repository, name: 'Moomins')
    expect(repository.committee_member?(moomintroll_user)).to be_falsy
  end

  it 'knows if a user is a data coordinator', focus: false do
    harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(harold_user)
    repository = FactoryGirl.create(:repository, name: 'Moomins')
    repository.repository_users.build(username: 'hbaines', data_coordinator: true)
    repository.save!
    harold_user = User.where(username: 'hbaines').first
    expect(repository.repository_coordinator?(harold_user)).to be_truthy
    expect(repository.data_coordinator?(harold_user)).to be_truthy
  end

  it 'knows if a user is not a data coordinator', focus: false do
    moomintroll_user = FactoryGirl.create(:user, email: 'moomintroll@moomin.com', username: 'moomintroll', first_name: 'Moomintroll', last_name: 'Moomin')
    moomintroll_user = User.where(username: 'moomintroll').first
    repository = FactoryGirl.create(:repository, name: 'Moomins')
    expect(repository.repository_coordinator?(moomintroll_user)).to be_falsy
    expect(repository.data_coordinator?(moomintroll_user)).to be_falsy
  end

  it 'knows if a user is a specimen coordinator', focus: false do
    harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(harold_user)
    repository = FactoryGirl.create(:repository, name: 'Moomins')
    repository.repository_users.build(username: 'hbaines', specimen_coordinator: true)
    repository.save!
    harold_user = User.where(username: 'hbaines').first
    expect(repository.repository_coordinator?(harold_user)).to be_truthy
    expect(repository.specimen_coordinator?(harold_user)).to be_truthy
  end

  it 'knows if a user is not a data coordinator', focus: false do
    moomintroll_user = FactoryGirl.create(:user, email: 'moomintroll@moomin.com', username: 'moomintroll', first_name: 'Moomintroll', last_name: 'Moomin')
    moomintroll_user = User.where(username: 'moomintroll').first
    repository = FactoryGirl.create(:repository, name: 'Moomins')
    expect(repository.repository_coordinator?(moomintroll_user)).to be_falsy
    expect(repository.specimen_coordinator?(moomintroll_user)).to be_falsy
  end

  it 'knows its specimen coordinators', focus: false do
    harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(harold)
    repository = FactoryGirl.create(:repository, name: 'Moomins')
    repository.repository_users.build(username: 'hbaines', specimen_coordinator: true)
    repository.save!
    harold_user = User.where(username: 'hbaines').first
    paul = { username: 'pkonerko', first_name: 'Paul', last_name: 'Konerko', email: 'pkonerko@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(paul)
    repository.repository_users.build(username: 'pkonerko', specimen_coordinator: false)
    repository.save!
    paul_user = User.where(username: 'pkonerko').first

    expect(repository.specimen_coordinators).to match_array([harold_user])
  end

  it 'knows its specimen coordinators', focus: false do
    harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(harold)
    repository = FactoryGirl.create(:repository, name: 'Moomins')
    repository.repository_users.build(username: 'hbaines', data_coordinator: true)
    repository.save!
    harold_user = User.where(username: 'hbaines').first
    paul = { username: 'pkonerko', first_name: 'Paul', last_name: 'Konerko', email: 'pkonerko@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(paul)
    repository.repository_users.build(username: 'pkonerko', data_coordinator: false)
    repository.save!
    paul_user = User.where(username: 'pkonerko').first

    expect(repository.data_coordinators).to match_array([harold_user])
  end

  it 'knows its repository administrators', focus: false do
    harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(harold)
    repository = FactoryGirl.create(:repository, name: 'Moomins')
    repository.repository_users.build(username: 'hbaines', administrator: true)
    repository.save!
    harold_user = User.where(username: 'hbaines').first
    paul = { username: 'pkonerko', first_name: 'Paul', last_name: 'Konerko', email: 'pkonerko@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(paul)
    repository.repository_users.build(username: 'pkonerko', administrator: false)
    repository.save!
    paul_user = User.where(username: 'pkonerko').first

    expect(repository.repository_administrators).to match_array([harold_user])
  end

  it 'knows its repository administrators (optionally including system administrator)', focus: false do
    harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(harold)
    repository = FactoryGirl.create(:repository, name: 'Moomins')
    repository.repository_users.build(username: 'hbaines', administrator: true)
    repository.save!
    harold_user = User.where(username: 'hbaines').first
    paul = { username: 'pkonerko', first_name: 'Paul', last_name: 'Konerko', email: 'pkonerko@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(paul)
    repository.repository_users.build(username: 'pkonerko', administrator: false)
    repository.save!
    paul_user = User.where(username: 'pkonerko').first
    moomintroll_user = FactoryGirl.create(:user, email: 'moomintroll@moomin.com', username: 'moomintroll', first_name: 'Moomintroll', last_name: 'Moomin', system_administrator: true)
    expect(repository.repository_administrators(include_system_administrtors: true)).to match_array([harold_user, moomintroll_user])
    expect(repository.repository_administrators(include_system_administrtors: false)).to match_array([harold_user])
    expect(repository.repository_administrators).to match_array([harold_user])
  end
end
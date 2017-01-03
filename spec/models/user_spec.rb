require 'rails_helper'
require 'active_support'

RSpec.describe User, type: :model do
  it { should have_many :repository_users }
  it { should have_many :repositories }

  before(:each) do
    @repository_moomin = FactoryGirl.create(:repository, name: 'Moomins', data: true, specimens: false)
  end

  it 'can search ldap by a token', focus: false do
    moomin = [{ username: 'moominpapa', first_name: 'moominpapa', last_name: 'moomin', email: 'moomin@moomin.com' }]
    allow(User).to receive(:find_ldap_entries_by_name).and_return(moomin)
    expect(User.search_ldap('Moomin')).to match_array(moomin)
  end

  it 'can search ldap by multiple tokens and filter the results', focus: false do
    moomins = [{ username: 'moominpapa', first_name: 'Moominpapa', last_name: 'Moomin', email: 'moominpapa@moomin.com' }, { username: 'moominmamma', first_name: 'Moominmamma', last_name: 'Moomin', email: 'moominmamma@moomin.com' }]
    moominpapa = [{ username: 'moominpapa', first_name: 'Moominpapa', last_name: 'Moomin', email: 'moominpapa@moomin.com' }]
    allow(User).to receive(:find_ldap_entries_by_name).with('moomin').and_return(moomins)
    allow(User).to receive(:find_ldap_entries_by_name).with('moominpapa').and_return(moominpapa)
    expect(User.search_ldap('moomin moominpapa')).to match_array(moominpapa)
  end

  it 'can search ldap by a token and filter the results to not include existing users', focus: false do
    email = 'moomin@moomin.com'
    username = 'moomin'
    first_name = 'Moominpapa'
    last_name = 'Moomin'
    user = FactoryGirl.create(:user, email: email, username: username, first_name: first_name, last_name: last_name)
    repository = FactoryGirl.build(:repository, name: 'Test Repository')
    FactoryGirl.create(:repository_user, user: user, repository: repository, username: username)
    moominpapa = [{ username: username, first_name: first_name, last_name: last_name, email: email }]
    allow(User).to receive(:find_ldap_entries_by_name).and_return(moominpapa)
    expect(User.search_ldap('Moomin', repository)).to be_empty
  end

  it "can extact the 'uid' property from an ldap 'dn'", focus: false do
    expect(User.extract_uid_from_dn("uid=mjg994, ou=People, dc=northwestern, dc=edu")).to eq('mjg994')
  end

  it 'can hydrate properties from ldap', focus: false do
    user = FactoryGirl.build(:user, username: 'moomin')
    moomin = { username: 'moominpapa', first_name: 'moominpapa', last_name: 'moomin', email: 'moomin@moomin.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(moomin)
    user.hydrate_from_ldap
    expect(user.first_name).to eq(moomin[:first_name])
    expect(user.last_name).to eq(moomin[:last_name])
    expect(user.email).to eq(moomin[:email])
  end

  it 'know if it is a repository administrator', focus: false do
    harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com', administator: true,  committee: false, specimen_resource: false, data_resource: false }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
    @repository_moomin.repository_users.build(username: 'hbaines', administrator: true)
    @repository_moomin.save!
    harold_user = User.where(username: 'hbaines').first
    expect(harold_user.repository_administrator?).to be_truthy
  end

  it 'know if it is not a repository administrator', focus: false do
    harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com', administator: true,  committee: false, specimen_resource: false, data_resource: false }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
    @repository_moomin.repository_users.build(username: 'hbaines', administrator: false, committee: true)
    @repository_moomin.save!
    harold_user = User.where(username: 'hbaines').first
    expect(harold_user.repository_administrator?).to be_falsy
  end
end
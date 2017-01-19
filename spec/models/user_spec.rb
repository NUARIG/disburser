require 'rails_helper'
require 'active_support'

RSpec.describe User, type: :model do
  it { should have_many :repository_users }
  it { should have_many :repositories }

  before(:each) do
    @moomin_repository = FactoryGirl.create(:repository, name: 'Moomins')
    @white_sox_repository = FactoryGirl.create(:repository, name: 'White Sox')
    @moomintroll_user = FactoryGirl.create(:user, email: 'moomintroll@moomin.com', username: 'moomintroll', first_name: 'Moomintroll', last_name: 'Moomin')
    @paul_user = FactoryGirl.create(:user, email: 'paulie@whitesox.com', username: 'pkonerko', first_name: 'Paul', last_name: 'Konerko')
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
    harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com', administator: true,  committee: false, specimen_coordinator: false, data_coordinator: false }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
    @moomin_repository.repository_users.build(username: 'hbaines', administrator: true)
    @moomin_repository.save!
    harold_user = User.where(username: 'hbaines').first
    expect(harold_user.repository_administrator?).to be_truthy
  end

  it 'know if it is not a repository administrator', focus: false do
    harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com', administator: true,  committee: false, specimen_coordinator: false, data_coordinator: false }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
    @moomin_repository.repository_users.build(username: 'hbaines', administrator: false, committee: true)
    @moomin_repository.save!
    harold_user = User.where(username: 'hbaines').first
    expect(harold_user.repository_administrator?).to be_falsy
  end

  it "can present a user's full name", focus: false do
    expect(@moomintroll_user.full_name).to eq('Moomintroll Moomin')
  end

  it 'know if it is a repository coordinator', focus: false do
    harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
    @moomin_repository.repository_users.build(username: 'hbaines', data_coordinator: true)
    @moomin_repository.save!
    harold_user = User.where(username: 'hbaines').first
    expect(harold_user.repository_coordinator?).to be_truthy
  end

  it 'know if it is not a repository coordinator', focus: false do
    harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
    @moomin_repository.repository_users.build(username: 'hbaines', data_coordinator: false, specimen_coordinator: false)
    @moomin_repository.save!
    harold_user = User.where(username: 'hbaines').first
    expect(harold_user.repository_coordinator?).to be_falsy
  end

  describe 'listing disburser requests' do
    before(:each) do
      @disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Groke research', investigator: 'Groke', irb_number: '123', cohort_criteria: 'Groke cohort criteria', data_for_cohort: 'Groke data for cohort')
      @disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Moomin research', investigator: 'Moominpapa', irb_number: '456', cohort_criteria: 'Momomin cohort criteria', data_for_cohort: 'Momomin data for cohort')
      @disburser_request_3 = FactoryGirl.create(:disburser_request, repository: @white_sox_repository, submitter: @paul_user, title: 'Sox baseball research', investigator: 'Nellie Fox', irb_number: '789', cohort_criteria: 'Sox cohort criteria', data_for_cohort: 'Sox data for cohort')
      @disburser_request_4 = FactoryGirl.create(:disburser_request, repository: @white_sox_repository, submitter: @moomintroll_user, title: 'White Sox research', investigator: 'Wilbur Wood', irb_number: '999', cohort_criteria: 'White Sox cohort criteria', data_for_cohort: 'White Sox data for cohort')
    end

    it 'lists admin disburser requests for a system administrator', focus: false do
      @paul_user.system_administrator = true
      @paul_user.save!

      expect(@paul_user.admin_disbursr_requests.all).to match_array([@disburser_request_1, @disburser_request_2, @disburser_request_3, @disburser_request_4])
    end

    it 'lists admin disburser requests for a repository administrator', focus: false do
      harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
      @moomin_repository.repository_users.build(username: 'hbaines', administrator: true)
      @moomin_repository.save!
      harold_user = User.where(username: 'hbaines').first
      expect(harold_user.admin_disbursr_requests.all).to match_array([@disburser_request_1, @disburser_request_2])
    end

    it 'lists coordinator disburser requests for a repository coordinator', focus: false do
      harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
      @moomin_repository.repository_users.build(username: 'hbaines', data_coordinator: true)
      @moomin_repository.save!
      harold_user = User.where(username: 'hbaines').first
      expect(harold_user.coordinator_disbursr_requests.all).to match_array([@disburser_request_1, @disburser_request_2])
    end

    it 'lists coordinator disburser requests for a repository coordinator by status', focus: false do
      harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
      @moomin_repository.repository_users.build(username: 'hbaines', data_coordinator: true)
      @moomin_repository.save!
      harold_user = User.where(username: 'hbaines').first
      @disburser_request_1.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
      @disburser_request_1.status_user = harold_user
      @disburser_request_1.save!
      expect(harold_user.coordinator_disbursr_requests(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED).all).to match_array([@disburser_request_1])
    end
  end
end
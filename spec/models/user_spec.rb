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
    @nellie_user = FactoryGirl.create(:user, email: 'nellie@whitesox.com', username: 'nfox', first_name: 'Nellie', last_name: 'Fox')
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

  it 'knows if it is a repository administrator', focus: false do
    harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
    @moomin_repository.repository_users.build(username: 'hbaines', administrator: true)
    @moomin_repository.save!
    harold_user = User.where(username: 'hbaines').first
    expect(harold_user.repository_administrator?).to be_truthy
  end

  it 'knows if it is not a repository administrator', focus: false do
    harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
    @moomin_repository.repository_users.build(username: 'hbaines', administrator: false, committee: true)
    @moomin_repository.save!
    harold_user = User.where(username: 'hbaines').first
    expect(harold_user.repository_administrator?).to be_falsy
  end

  it 'knows if it is a committee member', focus: false do
    harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
    @moomin_repository.repository_users.build(username: 'hbaines', committee: true)
    @moomin_repository.save!
    harold_user = User.where(username: 'hbaines').first
    expect(harold_user.committee?).to be_truthy
  end

  it 'knows if it is not a committee member', focus: false do
    harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
    @moomin_repository.repository_users.build(username: 'hbaines', administrator: true, committee: false)
    @moomin_repository.save!
    harold_user = User.where(username: 'hbaines').first
    expect(harold_user.committee?).to be_falsy
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

  it 'know if it is a data coordinator', focus: false do
    harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
    @moomin_repository.repository_users.build(username: 'hbaines', data_coordinator: true)
    @moomin_repository.save!
    harold_user = User.where(username: 'hbaines').first
    expect(harold_user.data_coordinator?).to be_truthy
  end

  it 'know if it is not a repository coordinator', focus: false do
    harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
    @moomin_repository.repository_users.build(username: 'hbaines', data_coordinator: false, specimen_coordinator: false)
    @moomin_repository.save!
    harold_user = User.where(username: 'hbaines').first
    expect(harold_user.data_coordinator?).to be_falsy
  end

  it 'know if it is a specimen coordinator', focus: false do
    harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
    @moomin_repository.repository_users.build(username: 'hbaines', specimen_coordinator: true)
    @moomin_repository.save!
    harold_user = User.where(username: 'hbaines').first
    expect(harold_user.specimen_coordinator?).to be_truthy
  end

  it 'know if it is not a repository coordinator', focus: false do
    harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
    allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
    @moomin_repository.repository_users.build(username: 'hbaines', data_coordinator: false, specimen_coordinator: false)
    @moomin_repository.save!
    harold_user = User.where(username: 'hbaines').first
    expect(harold_user.specimen_coordinator?).to be_falsy
  end

  describe 'listing disburser requests' do
    before(:each) do
      @disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Groke research', investigator: 'Groke', irb_number: '123', cohort_criteria: 'Groke cohort criteria', data_for_cohort: 'Groke data for cohort', status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @nellie_user)
      @disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Moomin research', investigator: 'Moominpapa', irb_number: '456', cohort_criteria: 'Momomin cohort criteria', data_for_cohort: 'Momomin data for cohort', status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @nellie_user)
      @disburser_request_3 = FactoryGirl.create(:disburser_request, repository: @white_sox_repository, submitter: @paul_user, title: 'Sox baseball research', investigator: 'Nellie Fox', irb_number: '789', cohort_criteria: 'Sox cohort criteria', data_for_cohort: 'Sox data for cohort', status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @nellie_user)
      @disburser_request_4 = FactoryGirl.create(:disburser_request, repository: @white_sox_repository, submitter: @moomintroll_user, title: 'White Sox research', investigator: 'Wilbur Wood', irb_number: '999', cohort_criteria: 'White Sox cohort criteria', data_for_cohort: 'White Sox data for cohort', status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @nellie_user)
      @disburser_request_5 = FactoryGirl.create(:disburser_request, repository: @white_sox_repository, submitter: @moomintroll_user, title: 'White Sox research 2', investigator: 'Wilbur Wood 2', irb_number: '9999', cohort_criteria: 'White Sox cohort criteria 2', data_for_cohort: 'White Sox data for cohort 2')
    end

    it 'lists admin disburser requests for a system administrator (excluding drafts)', focus: false do
      @paul_user.system_administrator = true
      @paul_user.save!

      expect(@paul_user.admin_disbursr_requests.all).to match_array([@disburser_request_1, @disburser_request_2, @disburser_request_3, @disburser_request_4])
    end

    it 'lists admin disburser requests for a repository administrator (excluding drafts) from a only administered repository', focus: false do
      harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
      @white_sox_repository.repository_users.build(username: 'hbaines', administrator: true)
      @white_sox_repository.save!
      harold_user = User.where(username: 'hbaines').first
      expect(harold_user.admin_disbursr_requests.all).to match_array([@disburser_request_3, @disburser_request_4])
    end

    it 'lists data coordinator disburser requests for a data coordinator (excluding drafts)', focus: false do
      harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
      @white_sox_repository.repository_users.build(username: 'hbaines', data_coordinator: true)
      @white_sox_repository.save!
      harold_user = User.where(username: 'hbaines').first

      expect(harold_user.data_coordinator_disbursr_requests.all).to match_array([@disburser_request_3, @disburser_request_4])
    end

    it 'lists data coordinator disburser requests for a data coordinator (excluding drafts) by status', focus: false do
      harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
      @white_sox_repository.repository_users.build(username: 'hbaines', data_coordinator: true)
      @white_sox_repository.save!
      harold_user = User.where(username: 'hbaines').first
      @disburser_request_3.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
      @disburser_request_3.status_user = harold_user
      @disburser_request_3.save!

      expect(harold_user.data_coordinator_disbursr_requests(status: DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW).all).to match_array([@disburser_request_3])
    end

    it 'lists data coordinator disburser requests for a data coordinator (excluding drafts) by data status', focus: false do
      harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
      @white_sox_repository.repository_users.build(username: 'hbaines', data_coordinator: true)
      @white_sox_repository.save!
      harold_user = User.where(username: 'hbaines').first
      @disburser_request_3.data_status = DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED
      @disburser_request_3.status_user = harold_user
      @disburser_request_3.save!

      expect(harold_user.data_coordinator_disbursr_requests(data_status: DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED).all).to match_array([@disburser_request_3])
    end

    it 'lists data coordinator disburser requests for a data coordinator (excluding drafts) by speciemn status', focus: false do
      harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
      @white_sox_repository.repository_users.build(username: 'hbaines', data_coordinator: true)
      @white_sox_repository.save!
      harold_user = User.where(username: 'hbaines').first
      @disburser_request_3.specimen_status = DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED
      @disburser_request_3.status_user = harold_user
      @disburser_request_3.save!

      expect(harold_user.data_coordinator_disbursr_requests(specimen_status: DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED).all).to match_array([@disburser_request_3])
    end

    it 'lists specimen coordinator disburser requests for a s coordinator (excluding drafts)', focus: false do
      harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
      @white_sox_repository.repository_users.build(username: 'hbaines', specimen_coordinator: true)
      @white_sox_repository.save!
      harold_user = User.where(username: 'hbaines').first

      expect(harold_user.specimen_coordinator_disbursr_requests.all).to match_array([@disburser_request_3, @disburser_request_4])
    end

    it 'lists specimen coordinator disburser requests for a specimen coordinator (excluding drafts) by status', focus: false do
      harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
      @white_sox_repository.repository_users.build(username: 'hbaines', specimen_coordinator: true)
      @white_sox_repository.save!
      harold_user = User.where(username: 'hbaines').first
      @disburser_request_3.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
      @disburser_request_3.status_user = harold_user
      @disburser_request_3.save!

      expect(harold_user.specimen_coordinator_disbursr_requests(status: DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW).all).to match_array([@disburser_request_3])
    end

    it 'lists specimen coordinator disburser requests for a specimen coordinator (excluding drafts) by data status', focus: false do
      harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
      @white_sox_repository.repository_users.build(username: 'hbaines', specimen_coordinator: true)
      @white_sox_repository.save!
      harold_user = User.where(username: 'hbaines').first
      @disburser_request_3.data_status = DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED
      @disburser_request_3.status_user = harold_user
      @disburser_request_3.save

      expect(harold_user.specimen_coordinator_disbursr_requests(data_status: DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED).all).to match_array([@disburser_request_3])
    end

    it 'lists specimen coordinator disburser requests for a specimen coordinator (excluding drafts) by specimen status', focus: false do
      harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
      @white_sox_repository.repository_users.build(username: 'hbaines', specimen_coordinator: true)
      @white_sox_repository.save!
      harold_user = User.where(username: 'hbaines').first
      @disburser_request_3.specimen_status = DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED
      @disburser_request_3.status_user = harold_user
      @disburser_request_3.save

      expect(harold_user.specimen_coordinator_disbursr_requests(specimen_status: DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED).all).to match_array([@disburser_request_3])
    end


    it 'lists committee disburser requests for a committee member (but only non-feasiblity requests)', focus: false do
      [@disburser_request_1, @disburser_request_2, @disburser_request_3, @disburser_request_4, @disburser_request_5].each do |disburser_request|
        disburser_request.feasibility = 0
        disburser_request.save!
      end

      harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
      @white_sox_repository.repository_users.build(username: 'hbaines', committee: true)
      @white_sox_repository.save!
      harold_user = User.where(username: 'hbaines').first
      [@disburser_request_1, @disburser_request_2, @disburser_request_3, @disburser_request_4, @disburser_request_5].each do |disburser_request|
        disburser_request.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
        disburser_request.status_user = @nellie_user
        disburser_request.save!
      end
      expect(harold_user.committee_disburser_requests.all).to match_array([@disburser_request_3, @disburser_request_4, @disburser_request_5])
      [@disburser_request_1, @disburser_request_2, @disburser_request_3, @disburser_request_4, @disburser_request_5].each do |disburser_request|
        disburser_request.feasibility = 1
        disburser_request.save!
      end
      expect(harold_user.committee_disburser_requests.all).to be_empty
    end

    it 'lists committee disburser requests for a committee member (only reviewable)', focus: false do
      [@disburser_request_1, @disburser_request_2, @disburser_request_3, @disburser_request_4, @disburser_request_5].each do |disburser_request|
        disburser_request.feasibility = 0
        disburser_request.save!
      end

      harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
      @white_sox_repository.repository_users.build(username: 'hbaines', committee: true)
      @white_sox_repository.save!
      harold_user = User.where(username: 'hbaines').first
      expect(harold_user.committee_disburser_requests.all).to be_empty
      DisburserRequest::DISBURSER_REQUEST_STATUSES_REVIEWABLE.each do |disburser_request_status_reviewable|
        @disburser_request_1.status = disburser_request_status_reviewable
        @disburser_request_1.status_user = @nellie_user
        @disburser_request_1.save

        @disburser_request_2.status = disburser_request_status_reviewable
        @disburser_request_2.status_user = @nellie_user
        @disburser_request_2.save

        @disburser_request_3.status = disburser_request_status_reviewable
        @disburser_request_3.status_user = @nellie_user
        @disburser_request_3.save

        @disburser_request_4.status = disburser_request_status_reviewable
        @disburser_request_4.status_user = @nellie_user
        @disburser_request_4.save

        @disburser_request_5.status = disburser_request_status_reviewable
        @disburser_request_5.status_user = @nellie_user
        @disburser_request_5.save
        expect(harold_user.committee_disburser_requests.all).to match_array([@disburser_request_3, @disburser_request_4, @disburser_request_5])
      end
    end

    it 'lists committee disburser requests for a committee member (only reviewable) by status', focus: false do
      [@disburser_request_1, @disburser_request_2, @disburser_request_3, @disburser_request_4, @disburser_request_5].each do |disburser_request|
        disburser_request.feasibility = 0
        disburser_request.save!
      end

      harold_user = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com' }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold_user)
      @white_sox_repository.repository_users.build(username: 'hbaines', committee: true)
      @white_sox_repository.save!
      harold_user = User.where(username: 'hbaines').first
      expect(harold_user.committee_disburser_requests.all).to be_empty

      @disburser_request_3.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
      @disburser_request_3.status_user = @nellie_user
      @disburser_request_3.save

      @disburser_request_4.status = DisburserRequest::DISBURSER_REQUEST_STATUS_APPROVED
      @disburser_request_4.status_user = @nellie_user
      @disburser_request_4.save

      @disburser_request_5.status = DisburserRequest::DISBURSER_REQUEST_STATUS_DENIED
      @disburser_request_5.status_user = @nellie_user
      @disburser_request_5.save

      expect(harold_user.committee_disburser_requests(status: DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW).all).to match_array([@disburser_request_3])
      expect(harold_user.committee_disburser_requests(status: DisburserRequest::DISBURSER_REQUEST_STATUS_APPROVED).all).to match_array([@disburser_request_4])
      expect(harold_user.committee_disburser_requests(status: DisburserRequest::DISBURSER_REQUEST_STATUS_DENIED).all).to match_array([@disburser_request_5])

      @disburser_request_5.status = DisburserRequest::DISBURSER_REQUEST_STATUS_CANCELED
      @disburser_request_5.status_user = @nellie_user
      @disburser_request_5.save
      expect(harold_user.committee_disburser_requests(status: DisburserRequest::DISBURSER_REQUEST_STATUS_CANCELED).all).to match_array([@disburser_request_5])
    end
  end
end
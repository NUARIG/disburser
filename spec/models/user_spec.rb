require 'rails_helper'
require 'active_support'

RSpec.describe User, type: :model do
  it { should have_many :repository_users }
  it { should have_many :repositories }
  it { should have_many :disburser_requests }

  before(:each) do
    @moomin_repository = FactoryGirl.create(:repository, name: 'Moomins')
    @white_sox_repository = FactoryGirl.create(:repository, name: 'White Sox')
    @moomintroll_user = FactoryGirl.create(:northwestern_user, email: 'moomintroll@moomin.com', username: 'moomintroll', first_name: 'Moomintroll', last_name: 'Moomin')
    @paul_user = FactoryGirl.create(:northwestern_user, email: 'paulie@whitesox.com', username: 'pkonerko', first_name: 'Paul', last_name: 'Konerko')
    @nellie_user = FactoryGirl.create(:northwestern_user, email: 'nellie@whitesox.com', username: 'nfox', first_name: 'Nellie', last_name: 'Fox')
  end

  it "can present a user's full name", focus: false do
    expect(@moomintroll_user.full_name).to eq('Moomintroll Moomin')
  end

  it 'knows if it is a repository administrator', focus: false do
    @moomin_repository.repository_users.build(username: @nellie_user.username, administrator: true)
    @moomin_repository.save!
    expect(@nellie_user.repository_administrator?).to be_truthy
  end

  it 'knows if it is not a repository administrator', focus: false do
    @moomin_repository.repository_users.build(username: @nellie_user.username, administrator: false)
    @moomin_repository.save!
    expect(@nellie_user.repository_administrator?).to be_falsy
  end

  it 'knows if it is a committee member', focus: false do
    @moomin_repository.repository_users.build(username: @nellie_user.username, committee: true)
    @moomin_repository.save!
    expect(@nellie_user.committee?).to be_truthy
  end

  it 'knows if it is not a committee member', focus: false do
    @moomin_repository.repository_users.build(username: @nellie_user.username, committee: false)
    @moomin_repository.save!
    expect(@nellie_user.committee?).to be_falsy
  end

  it 'know if it is a repository coordinator', focus: false do
    @moomin_repository.repository_users.build(username: @nellie_user.username, data_coordinator: true)
    @moomin_repository.save!
    expect(@nellie_user.repository_coordinator?).to be_truthy
  end

  it 'know if it is not a repository coordinator', focus: false do
    @moomin_repository.repository_users.build(username: @nellie_user.username, data_coordinator: false, specimen_coordinator: false)
    @moomin_repository.save!
    expect(@nellie_user.repository_coordinator?).to be_falsy
  end

  it 'know if it is a data coordinator', focus: false do
    @moomin_repository.repository_users.build(username: @nellie_user.username, data_coordinator: true)
    @moomin_repository.save!
    expect(@nellie_user.data_coordinator?).to be_truthy
  end

  it 'know if it is not a data coordinator', focus: false do
    @moomin_repository.repository_users.build(username: @nellie_user.username, data_coordinator: false)
    @moomin_repository.save!
    expect(@nellie_user.data_coordinator?).to be_falsy
  end

  it 'know if it is a specimen coordinator', focus: false do
    @moomin_repository.repository_users.build(username: @nellie_user.username, specimen_coordinator: true)
    @moomin_repository.save!
    expect(@nellie_user.specimen_coordinator?).to be_truthy
  end

  it 'know if it is not a repository coordinator', focus: false do
    @moomin_repository.repository_users.build(username: @nellie_user.username, specimen_coordinator: false)
    @moomin_repository.save!
    expect(@nellie_user.specimen_coordinator?).to be_falsy
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
      @white_sox_repository.repository_users.build(username: @nellie_user.username, administrator: true)
      @white_sox_repository.save!

      expect(@nellie_user.admin_disbursr_requests.all).to match_array([@disburser_request_3, @disburser_request_4])
    end

    it 'lists data coordinator disburser requests for a data coordinator (excluding drafts)', focus: false do
      @white_sox_repository.repository_users.build(username: @nellie_user.username, data_coordinator: true)
      @white_sox_repository.save!

      expect(@nellie_user.data_coordinator_disbursr_requests.all).to match_array([@disburser_request_3, @disburser_request_4])
    end

    it 'lists data coordinator disburser requests for a data coordinator (excluding drafts) by status', focus: false do
      @white_sox_repository.repository_users.build(username: @nellie_user.username, data_coordinator: true)
      @white_sox_repository.save!
      @disburser_request_3.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
      @disburser_request_3.status_user = @nellie_user
      @disburser_request_3.save!

      expect(@nellie_user.data_coordinator_disbursr_requests(status: DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW).all).to match_array([@disburser_request_3])
    end

    it 'lists data coordinator disburser requests for a data coordinator (excluding drafts) by data status', focus: false do
      @white_sox_repository.repository_users.build(username: @nellie_user.username, data_coordinator: true)
      @white_sox_repository.save!
      @disburser_request_3.data_status = DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED
      @disburser_request_3.status_user = @nellie_user
      @disburser_request_3.save!

      expect(@nellie_user.data_coordinator_disbursr_requests(data_status: DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED).all).to match_array([@disburser_request_3])
    end

    it 'lists data coordinator disburser requests for a data coordinator (excluding drafts) by speciemn status', focus: false do
      @white_sox_repository.repository_users.build(username: @nellie_user.username, data_coordinator: true)
      @white_sox_repository.save!
      @disburser_request_3.specimen_status = DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED
      @disburser_request_3.status_user = @nellie_user
      @disburser_request_3.save!

      expect(@nellie_user.data_coordinator_disbursr_requests(specimen_status: DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED).all).to match_array([@disburser_request_3])
    end

    it 'lists specimen coordinator disburser requests for a s coordinator (excluding drafts)', focus: false do
      @white_sox_repository.repository_users.build(username: @nellie_user.username, specimen_coordinator: true)
      @white_sox_repository.save!

      expect(@nellie_user.specimen_coordinator_disbursr_requests.all).to match_array([@disburser_request_3, @disburser_request_4])
    end

    it 'lists specimen coordinator disburser requests for a specimen coordinator (excluding drafts) by status', focus: false do
      @white_sox_repository.repository_users.build(username: @nellie_user.username, specimen_coordinator: true)
      @white_sox_repository.save!
      @disburser_request_3.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
      @disburser_request_3.status_user = @nellie_user
      @disburser_request_3.save!

      expect(@nellie_user.specimen_coordinator_disbursr_requests(status: DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW).all).to match_array([@disburser_request_3])
    end

    it 'lists specimen coordinator disburser requests for a specimen coordinator (excluding drafts) by data status', focus: false do
      @white_sox_repository.repository_users.build(username: @nellie_user.username, specimen_coordinator: true)
      @white_sox_repository.save!
      @disburser_request_3.data_status = DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED
      @disburser_request_3.status_user = @nellie_user
      @disburser_request_3.save

      expect(@nellie_user.specimen_coordinator_disbursr_requests(data_status: DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED).all).to match_array([@disburser_request_3])
    end

    it 'lists specimen coordinator disburser requests for a specimen coordinator (excluding drafts) by specimen status', focus: false do
      @white_sox_repository.repository_users.build(username: @nellie_user.username, specimen_coordinator: true)
      @white_sox_repository.save!
      @disburser_request_3.specimen_status = DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED
      @disburser_request_3.status_user = @nellie_user
      @disburser_request_3.save

      expect(@nellie_user.specimen_coordinator_disbursr_requests(specimen_status: DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED).all).to match_array([@disburser_request_3])
    end

    it 'lists committee disburser requests for a committee member (but only non-feasiblity requests)', focus: false do
      [@disburser_request_1, @disburser_request_2, @disburser_request_3, @disburser_request_4, @disburser_request_5].each do |disburser_request|
        disburser_request.feasibility = 0
        disburser_request.save!
      end

      @white_sox_repository.repository_users.build(username: @nellie_user.username, committee: true)
      @white_sox_repository.save!

      [@disburser_request_1, @disburser_request_2, @disburser_request_3, @disburser_request_4, @disburser_request_5].each do |disburser_request|
        disburser_request.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
        disburser_request.status_user = @nellie_user
        disburser_request.save!
      end
      expect(@nellie_user.committee_disburser_requests.all).to match_array([@disburser_request_3, @disburser_request_4, @disburser_request_5])
      [@disburser_request_1, @disburser_request_2, @disburser_request_3, @disburser_request_4, @disburser_request_5].each do |disburser_request|
        disburser_request.feasibility = 1
        disburser_request.save!
      end
      expect(@nellie_user.committee_disburser_requests.all).to be_empty
    end

    it 'lists committee disburser requests for a committee member (only reviewable)', focus: false do
      [@disburser_request_1, @disburser_request_2, @disburser_request_3, @disburser_request_4, @disburser_request_5].each do |disburser_request|
        disburser_request.feasibility = 0
        disburser_request.save!
      end

      @white_sox_repository.repository_users.build(username: @nellie_user.username, committee: true)
      @white_sox_repository.save!
      expect(@nellie_user.committee_disburser_requests.all).to be_empty
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
        expect(@nellie_user.committee_disburser_requests.all).to match_array([@disburser_request_3, @disburser_request_4, @disburser_request_5])
      end
    end

    it 'lists committee disburser requests for a committee member (only reviewable) by status', focus: false do
      [@disburser_request_1, @disburser_request_2, @disburser_request_3, @disburser_request_4, @disburser_request_5].each do |disburser_request|
        disburser_request.feasibility = 0
        disburser_request.save!
      end

      @white_sox_repository.repository_users.build(username: @nellie_user.username, committee: true)
      @white_sox_repository.save!
      expect(@nellie_user.committee_disburser_requests.all).to be_empty

      @disburser_request_3.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
      @disburser_request_3.status_user = @nellie_user
      @disburser_request_3.save

      @disburser_request_4.status = DisburserRequest::DISBURSER_REQUEST_STATUS_APPROVED
      @disburser_request_4.status_user = @nellie_user
      @disburser_request_4.save

      @disburser_request_5.status = DisburserRequest::DISBURSER_REQUEST_STATUS_DENIED
      @disburser_request_5.status_user = @nellie_user
      @disburser_request_5.save

      expect(@nellie_user.committee_disburser_requests(status: DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW).all).to match_array([@disburser_request_3])
      expect(@nellie_user.committee_disburser_requests(status: DisburserRequest::DISBURSER_REQUEST_STATUS_APPROVED).all).to match_array([@disburser_request_4])
      expect(@nellie_user.committee_disburser_requests(status: DisburserRequest::DISBURSER_REQUEST_STATUS_DENIED).all).to match_array([@disburser_request_5])

      @disburser_request_5.status = DisburserRequest::DISBURSER_REQUEST_STATUS_CANCELED
      @disburser_request_5.status_user = @nellie_user
      @disburser_request_5.save
      expect(@nellie_user.committee_disburser_requests(status: DisburserRequest::DISBURSER_REQUEST_STATUS_CANCELED).all).to match_array([@disburser_request_5])
    end
  end
end
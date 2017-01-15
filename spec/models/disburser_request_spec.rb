require 'rails_helper'
require 'active_support'

RSpec.describe DisburserRequest, type: :model do
  it { should belong_to :repository }
  it { should belong_to :submitter }
  it { should have_many :disburser_request_details }
  it { should have_many :disburser_request_statuses }

  it { should validate_presence_of :investigator }
  it { should validate_presence_of :title }
  it { should validate_presence_of :irb_number }
  it { should validate_presence_of :methods_justifications }
  it { should validate_presence_of :cohort_criteria }
  it { should validate_presence_of :data_for_cohort }

  before(:each) do
    @moomin_repository = FactoryGirl.build(:repository, name: 'Moomin Repository')
    @moomintroll_user = FactoryGirl.create(:user, email: 'moomintroll@moomin.com', username: 'moomintroll', first_name: 'Moomintroll', last_name: 'Moomin')
    @little_my_user = FactoryGirl.create(:user, email: 'little_my@moomin.com', username: 'little_my', first_name: 'Little My', last_name: 'Moomin')
  end


  it "defaults status to 'draft' for a new record that does not provide a status", focus: false do
    disburser_request = DisburserRequest.new
    expect(disburser_request.status).to eq(DisburserRequest::DISBURSER_REQUEST_STAUTS_DRAFT)
  end

  it "leaves status intact for a new record that provides a status", focus: false do
    disburser_request = DisburserRequest.new(status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
    expect(disburser_request.status).to eq(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
  end

  it 'can search accross fields (by title)', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Cure cancer', investigator: 'placehoder', irb_number: 'placehoder', cohort_criteria: 'placehoder', data_for_cohort: 'placehoder')
    disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Cure heart disease',  investigator: 'placehoder', irb_number: 'placehoder', cohort_criteria: 'placehoder', data_for_cohort: 'placehoder')
    expect(DisburserRequest.search_across_fields('Cancer')).to match_array([disburser_request_1])
  end

  it 'can search accross fields (by title) case insensitively', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Cure cancer', investigator: 'placehoder', irb_number: 'placehoder')
    disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Cure heart disease',  investigator: 'placehoder', irb_number: 'placehoder')
    expect(DisburserRequest.search_across_fields('CANCER')).to match_array([disburser_request_1])
  end

  it 'can search accross fields (by investigator)', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'placeholder', investigator: 'richard rorty', irb_number: 'placehoder')
    disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'placeholder',  investigator: 'daniel dennet', irb_number: 'placehoder')
    expect(DisburserRequest.search_across_fields('rorty')).to match_array([disburser_request_1])
  end

  it 'can search accross fields (by investigator) case insensitively', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'placeholder', investigator: 'richard rorty', irb_number: 'placehoder')
    disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'placeholder',  investigator: 'daniel dennet', irb_number: 'placehoder')
    expect(DisburserRequest.search_across_fields('RORTY')).to match_array([disburser_request_1])
  end

  it 'can search accross fields (by irb number)', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'placeholder', investigator: 'placehoder', irb_number: 'irb123')
    disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'placeholder',  investigator: 'placehoder', irb_number: 'irb789')
    expect(DisburserRequest.search_across_fields('irb123')).to match_array([disburser_request_1])
  end

  it 'can search accross fields (by irb number) case insensitively', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'placeholder', investigator: 'placehoder', irb_number: 'irb123')
    disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'placeholder',  investigator: 'placehoder', irb_number: 'irb789')
    expect(DisburserRequest.search_across_fields('IRB123')).to match_array([disburser_request_1])
  end

  it 'can search accross fields (and sort ascending/descending by a passed in column)', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'a', investigator: 'b')
    disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'b', investigator: 'a')

    expect(DisburserRequest.search_across_fields(nil, { sort_column: 'title', sort_direction: 'asc' })).to eq([disburser_request_1, disburser_request_2])
    expect(DisburserRequest.search_across_fields(nil, { sort_column: 'title', sort_direction: 'desc' })).to eq([disburser_request_2, disburser_request_1])

    expect(DisburserRequest.search_across_fields(nil, { sort_column: 'investigator', sort_direction: 'asc' })).to eq([disburser_request_2, disburser_request_1])
    expect(DisburserRequest.search_across_fields(nil, { sort_column: 'investigator', sort_direction: 'desc' })).to eq([disburser_request_1, disburser_request_2])
  end

  it 'knows if a request is mine', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    expect(disburser_request_1.mine?(@moomintroll_user)).to be_truthy
  end

  it 'knows if a request is not mine', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    expect(disburser_request_1.mine?(@little_my_user)).to be_falsy
  end

  it 'knows if a request is a draft', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, status: DisburserRequest::DISBURSER_REQUEST_STAUTS_DRAFT)
    expect(disburser_request_1.draft?).to be_truthy
  end

  it 'knows if a request is not a draft', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @moomintroll_user)
    expect(disburser_request_1.draft?).to be_falsy
  end

  it "saves a disburser request status once the status reaches 'submitted'", focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @moomintroll_user)
    expect(disburser_request_1.disburser_request_statuses.size).to eq(1)
    expect(disburser_request_1.disburser_request_statuses.first.status).to eq(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
    expect(disburser_request_1.disburser_request_statuses.first.username).to eq(@moomintroll_user.username)
  end

  it "saves a disburser request status once the status reaches 'submitted' (but only once)", focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @moomintroll_user)
    expect(disburser_request_1.disburser_request_statuses.size).to eq(1)
    expect(disburser_request_1.disburser_request_statuses.first.status).to eq(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
    expect(disburser_request_1.disburser_request_statuses.first.username).to eq(@moomintroll_user.username)
    disburser_request_1.title = 'moomin research'
    disburser_request_1.save!
    disburser_request_1.reload
    expect(disburser_request_1.disburser_request_statuses.size).to eq(1)
    expect(disburser_request_1.disburser_request_statuses.first.status).to eq(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
    expect(disburser_request_1.disburser_request_statuses.first.username).to eq(@moomintroll_user.username)
  end
end
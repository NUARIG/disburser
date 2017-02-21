require 'rails_helper'
require 'active_support'

RSpec.describe DisburserRequestStatus, type: :model do
  it { should belong_to :disburser_request }
  it { should belong_to :user }

  before(:each) do
    @moomin_repository = FactoryGirl.build(:repository, name: 'Moomin Repository')
    @moomintroll_user = FactoryGirl.create(:user, email: 'moomintroll@moomin.com', username: 'moomintroll', first_name: 'Moomintroll', last_name: 'Moomin')
    @little_my_user = FactoryGirl.create(:user, email: 'little_my@moomin.com', username: 'little_my', first_name: 'Little My', last_name: 'Moomin')
  end

  it 'lists disburser reqeust statuses by status type', focus: false do
    disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @little_my_user, status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @moomintroll_user, data_status: DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED)
    disburser_request.status_user = @moomintroll_user
    disburser_request.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
    disburser_request.specimen_status = DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED
    disburser_request.save!
    expect(disburser_request.disburser_request_statuses.size).to eq(4)
    expect(disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS).size).to eq(2)
    expect(disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS).map(&:status)).to match_array([DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW])
    expect(disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_DATA_STATUS).size).to eq(1)
    expect(disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_DATA_STATUS).map(&:status)).to match_array([DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED])
    expect(disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_SPECIMEN_STATUS).size).to eq(1)
    expect(disburser_request.disburser_request_statuses.by_status_type(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_SPECIMEN_STATUS).map(&:status)).to match_array([DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED])
  end
end
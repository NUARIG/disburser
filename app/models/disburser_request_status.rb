class DisburserRequestStatus < ApplicationRecord
  belongs_to :disburser_request, required: false
  belongs_to :user

  DISBURSER_REQUEST_STATUS_TYPE_STATUS = 'status'
  DISBURSER_REQUEST_STATUS_TYPE_FULLMILLMENT_STATUS = 'fulfillment_status'

  scope :by_status_type, (lambda do |status_type|
    where(status_type: status_type)
  end)
end
class DisburserRequestStatus < ApplicationRecord
  belongs_to :disburser_request, required: false
  belongs_to :user

  after_create :send_email_notificaitons

  DISBURSER_REQUEST_STATUS_TYPE_STATUS = 'status'
  DISBURSER_REQUEST_STATUS_TYPE_FULLMILLMENT_STATUS = 'fulfillment_status'

  scope :by_status_type, (lambda do |status_type|
    where(status_type: status_type)
  end)

  def send_email_notificaitons
    if !Rails.env.test?
      case self.status_type
      when DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS
        case self.status
        when DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
          DisburserRequestStatusMailer.status_submittted(self.disburser_request).deliver_now
          DisburserRequestStatusMailer.status_submittted_data_coordinator(self.disburser_request).deliver_now
          DisburserRequestStatusMailer.status_submittted_specimen_coordinator(self.disburser_request).deliver_now
          DisburserRequestStatusMailer.status_submittted_administrator(self.disburser_request).deliver_now
        when DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
          DisburserRequestStatusMailer.status_committee_review(self.disburser_request).deliver_now
        when DisburserRequest::DISBURSER_REQUEST_STATUS_APPROVED
          DisburserRequestStatusMailer.status_approved(self.disburser_request).deliver_now
          DisburserRequestStatusMailer.status_approved_data_coordinator(self.disburser_request).deliver_now
          DisburserRequestStatusMailer.status_approved_specimen_coordinator(self.disburser_request).deliver_now
        when DisburserRequest::DISBURSER_REQUEST_STATUS_DENIED
          DisburserRequestStatusMailer.status_denied(self.disburser_request).deliver_now
        when DisburserRequest::DISBURSER_REQUEST_STAUTS_CANCELED
          DisburserRequestStatusMailer.status_canceled(self.disburser_request).deliver_now
        end
      when DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_FULLMILLMENT_STATUS
        case self.status
        when DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED
          DisburserRequestStatusMailer.fulfillment_status_query_fulfilled_specimen_coordinator(self.disburser_request).deliver_now
          DisburserRequestStatusMailer.fulfillment_status_query_fulfilled_administrator(self.disburser_request).deliver_now
        when DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_INSUFFICIENT_DATA
          DisburserRequestStatusMailer.fulfillment_status_insufficient_data(self.disburser_request).deliver_now
        when DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_INVENTORY_FULFILLED
          DisburserRequestStatusMailer.fulfillment_status_inventory_fulfilled(self.disburser_request).deliver_now
        when DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_INSUFFICIENT_SPECIMENS
          DisburserRequestStatusMailer.fulfillment_status_insufficient_specimens(self.disburser_request).deliver_now
        end
      end
    end
  end
end
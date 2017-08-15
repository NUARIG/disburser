class DisburserRequestStatus < ApplicationRecord
  has_paper_trail
  belongs_to :disburser_request, required: false
  belongs_to :user
  validates_presence_of :status_at

  after_create :send_email_notificaitons

  DISBURSER_REQUEST_STATUS_TYPE_STATUS = 'status'
  DISBURSER_REQUEST_STATUS_TYPE_DATA_STATUS = 'data_status'
  DISBURSER_REQUEST_STATUS_TYPE_SPECIMEN_STATUS = 'specimen_status'
  DISBURSER_REQUEST_STATUS_TYPES = [DISBURSER_REQUEST_STATUS_TYPE_STATUS, DISBURSER_REQUEST_STATUS_TYPE_DATA_STATUS, DISBURSER_REQUEST_STATUS_TYPE_SPECIMEN_STATUS]

  def send_email_notificaitons
    if !Rails.env.test?
      case self.status_type
      when DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS
        case self.status
        when DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
          DisburserRequestStatusMailer.status_submittted(self.disburser_request).deliver_later
          DisburserRequestStatusMailer.status_submittted_data_coordinator(self.disburser_request).deliver_later
          DisburserRequestStatusMailer.status_submittted_specimen_coordinator(self.disburser_request).deliver_later
          DisburserRequestStatusMailer.status_submittted_administrator(self.disburser_request).deliver_later
        when DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
          DisburserRequestStatusMailer.status_committee_review(self.disburser_request).deliver_later
        when DisburserRequest::DISBURSER_REQUEST_STATUS_APPROVED
          DisburserRequestStatusMailer.status_approved(self.disburser_request).deliver_later
          DisburserRequestStatusMailer.status_approved_data_coordinator(self.disburser_request).deliver_later
          DisburserRequestStatusMailer.status_approved_specimen_coordinator(self.disburser_request).deliver_later
        when DisburserRequest::DISBURSER_REQUEST_STATUS_DENIED
          DisburserRequestStatusMailer.status_denied(self.disburser_request).deliver_later
        when DisburserRequest::DISBURSER_REQUEST_STATUS_CANCELED
          DisburserRequestStatusMailer.status_canceled(self.disburser_request).deliver_later
        end
      when DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_DATA_STATUS
        case self.status
        when DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_DATA_CHECKED
          DisburserRequestStatusMailer.data_status_data_checked_specimen_coordinator(self.disburser_request).deliver_later
          if disburser_request.repository.notify_repository_administrator
            DisburserRequestStatusMailer.data_status_data_checked_administrator(self.disburser_request).deliver_later
          end
        when DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_INSUFFICIENT_DATA
          DisburserRequestStatusMailer.data_status_insufficient_data(self.disburser_request).deliver_later
        when DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED
          if disburser_request.repository.notify_repository_administrator
            DisburserRequestStatusMailer.data_status_query_fulfilled_administrator(self.disburser_request).deliver_later
          end
        end
      when DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_SPECIMEN_STATUS
        case self.status
        when DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_CHECKED
          if disburser_request.repository.notify_repository_administrator
            DisburserRequestStatusMailer.specimen_status_inventory_checked(self.disburser_request).deliver_later
          end
        when DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INSUFFICIENT_SPECIMENS
          if disburser_request.repository.notify_repository_administrator
            DisburserRequestStatusMailer.specimen_status_insufficient_specimens(self.disburser_request).deliver_later
          end
        when DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED
          if disburser_request.repository.notify_repository_administrator
            DisburserRequestStatusMailer.specimen_status_inventory_fulfilled(self.disburser_request).deliver_later
          end
        end
      end
    end
  end
end
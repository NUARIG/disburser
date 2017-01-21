class DisburserRequest < ApplicationRecord
  belongs_to :repository
  belongs_to :submitter, class_name: 'User', foreign_key: :submitter_id
  has_many :disburser_request_details
  has_many :disburser_request_statuses
  accepts_nested_attributes_for :disburser_request_details, reject_if: :all_blank, allow_destroy: true
  validates_presence_of :investigator, :title, :methods_justifications, :cohort_criteria, :data_for_cohort, :fulfillment_status
  validates_presence_of :irb_number, if: Proc.new { |disburser_reqeust| !disburser_reqeust.feasibility }
  validates_associated :disburser_request_details

  mount_uploader :methods_justifications, MethodsJustificationsUploader

  after_initialize :set_defaults
  before_save :build_disburser_request_status
  attr_accessor :status_user, :status_comments

  DISBURSER_REQUEST_STAUTS_DRAFT = 'draft'
  DISBURSER_REQUEST_STATUS_SUBMITTED = 'submitted'
  DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW = 'committee review'
  DISBURSER_REQUEST_STATUS_APPROVED = 'approved'
  DISBURSER_REQUEST_STATUS_DENIED = 'denied'
  DISBURSER_REQUEST_STATUSES = [DISBURSER_REQUEST_STAUTS_DRAFT, DISBURSER_REQUEST_STATUS_SUBMITTED, DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW, DISBURSER_REQUEST_STATUS_APPROVED, DISBURSER_REQUEST_STATUS_DENIED]
  DISBURSER_REQUEST_STATUSES_SANS_DRAFT = DISBURSER_REQUEST_STATUSES - [DISBURSER_REQUEST_STAUTS_DRAFT]

  DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_NOT_STARTED = 'not started'
  DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED = 'query fulfilled'
  DISBURSER_REQUEST_FULFILLMENT_STATUS_INSUFFICIENT_DATA = 'insufficient data'
  DISBURSER_REQUEST_FULFILLMENT_STATUS_INVENTORY_FULFILLED = 'inventory fulfilled'
  DISBURSER_REQUEST_FULFILLMENT_STATUS_INSUFFICIENT_SPECIMENS = 'insufficient specimens'
  DISBURSER_REQUEST_FULFILLMENT_STATUSES = [DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_NOT_STARTED, DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED, DISBURSER_REQUEST_FULFILLMENT_STATUS_INSUFFICIENT_DATA, DISBURSER_REQUEST_FULFILLMENT_STATUS_INVENTORY_FULFILLED, DISBURSER_REQUEST_FULFILLMENT_STATUS_INSUFFICIENT_SPECIMENS]
  DISBURSER_REQUEST_DATA_FULFILLMENT_STATUSES = [DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED, DISBURSER_REQUEST_FULFILLMENT_STATUS_INSUFFICIENT_DATA]
  DISBURSER_REQUEST_SPECIMEN_FULFILLMENT_STATUSES = [DISBURSER_REQUEST_FULFILLMENT_STATUS_INVENTORY_FULFILLED, DISBURSER_REQUEST_FULFILLMENT_STATUS_INSUFFICIENT_SPECIMENS]

  scope :search_across_fields, ->(search_token, options={}) do
    if search_token
      search_token.downcase!
    end
    options = { sort_column: 'title', sort_direction: 'asc' }.merge(options)
    s = DisburserRequest
    s = s.joins(:submitter)
    s = s.joins(:repository)
    if search_token
      s = where(["lower(title) like ? OR lower(investigator) like ? OR lower(irb_number) like ?", "%#{search_token}%", "%#{search_token}%", "%#{search_token}%"])
    end

    sort = options[:sort_column] + ' ' + options[:sort_direction] + ', disburser_requests.id ASC'
    s = s.nil? ? order(sort) : s.order(sort)

    s
  end

  scope :not_draft, -> do
    where.not(status: DisburserRequest::DISBURSER_REQUEST_STAUTS_DRAFT)
  end

  def mine?(user)
    submitter == user
  end

  def draft?
    self.status == DisburserRequest::DISBURSER_REQUEST_STAUTS_DRAFT
  end

  def submitted?
    self.status == DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
  end

  def query_fulfilled?
    self.fulfillment_status == DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED
  end

  def not_started?
    self.fulfillment_status == DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_NOT_STARTED
  end

  def build_disburser_request_status
    if disburser_request_statuses.none? { |disburser_request_status| disburser_request_status.status == self.status && disburser_request_status.status_type = 'status' } && !self.draft?
      disburser_request_statuses.build(status_type: 'status', status: self.status, user_id: self.status_user.id, comments: self.status_comments)
    end

    if !self.not_started?
      disburser_request_statuses.build(status_type: 'fulfillment_status', status: self.fulfillment_status, user_id: self.status_user.id, comments: self.status_comments)
    end
  end

  private
    def set_defaults
      if self.new_record?
        if self.status.blank?
          self.status = DisburserRequest::DISBURSER_REQUEST_STAUTS_DRAFT
        end
        self.fulfillment_status = DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_NOT_STARTED
      end
    end
end
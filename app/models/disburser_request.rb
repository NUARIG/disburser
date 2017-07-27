class DisburserRequest < ApplicationRecord
  has_paper_trail
  belongs_to :repository
  belongs_to :submitter, class_name: 'User', foreign_key: :submitter_id
  has_many :disburser_request_details
  has_many :disburser_request_statuses
  has_many :disburser_request_votes
  accepts_nested_attributes_for :disburser_request_details, reject_if: :all_blank, allow_destroy: true
  validates_presence_of :investigator, :title, :specimen_status, :data_status, :status
  validates_presence_of :methods_justifications, if: Proc.new { |disburser_reqeust| !disburser_reqeust.use_custom_request_form }
  validates_presence_of :cohort_criteria, if: Proc.new { |disburser_reqeust| !disburser_reqeust.use_custom_request_form }
  validates_presence_of :data_for_cohort, if: Proc.new { |disburser_reqeust| !disburser_reqeust.use_custom_request_form }
  validates_presence_of :irb_number, if: Proc.new { |disburser_reqeust| !disburser_reqeust.feasibility }
  validates_presence_of :custom_request_form, if: Proc.new { |disburser_reqeust| disburser_reqeust.use_custom_request_form }
  validates_associated :disburser_request_details

  mount_uploader :methods_justifications, MethodsJustificationsUploader
  mount_uploader :custom_request_form, DisburserRequestCustomRequestFormUploader
  mount_uploader :supporting_document, DisburserRequestSupportingDocumentUploader

  after_initialize :set_defaults
  before_save :build_disburser_request_status
  attr_accessor :status_user, :status_comments, :data_status_comments, :specimen_status_comments

  DISBURSER_REQUEST_STAUTS_DRAFT = 'draft'
  DISBURSER_REQUEST_STATUS_SUBMITTED = 'submitted'
  DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW = 'committee review'
  DISBURSER_REQUEST_STATUS_APPROVED = 'approved'
  DISBURSER_REQUEST_STATUS_DENIED = 'denied'
  DISBURSER_REQUEST_STATUS_CANCELED = 'canceled'
  DISBURSER_REQUEST_STATUSES = [DISBURSER_REQUEST_STAUTS_DRAFT, DISBURSER_REQUEST_STATUS_SUBMITTED, DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW, DISBURSER_REQUEST_STATUS_APPROVED, DISBURSER_REQUEST_STATUS_DENIED, DISBURSER_REQUEST_STATUS_CANCELED]
  DISBURSER_REQUEST_STATUSES_SANS_DRAFT = DISBURSER_REQUEST_STATUSES - [DISBURSER_REQUEST_STAUTS_DRAFT]
  DISBURSER_REQUEST_STATUSES_REVIEWABLE = [DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW, DISBURSER_REQUEST_STATUS_APPROVED, DISBURSER_REQUEST_STATUS_DENIED, DISBURSER_REQUEST_STATUS_CANCELED]

  DISBURSER_REQUEST_DATA_STATUS_NOT_STARTED = 'not started'
  DISBURSER_REQUEST_DATA_STATUS_DATA_CHECKED = 'data checked'
  DISBURSER_REQUEST_DATA_STATUS_INSUFFICIENT_DATA = 'insufficient data'
  DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED = 'query fulfilled'
  DISBURSER_REQUEST_DATA_STATUSES = [DISBURSER_REQUEST_DATA_STATUS_NOT_STARTED, DISBURSER_REQUEST_DATA_STATUS_DATA_CHECKED, DISBURSER_REQUEST_DATA_STATUS_INSUFFICIENT_DATA, DISBURSER_REQUEST_DATA_STATUS_QUERY_FULFILLED]
  DISBURSER_REQUEST_DATA_STATUSES_SANS_NOT_STARTED = DISBURSER_REQUEST_DATA_STATUSES - [DISBURSER_REQUEST_DATA_STATUS_NOT_STARTED]

  DISBURSER_REQUEST_SPECIMEN_STATUS_NOT_STARTED = 'not started'
  DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_CHECKED = 'inventory checked'
  DISBURSER_REQUEST_SPECIMEN_STATUS_INSUFFICIENT_SPECIMENS = 'insufficient specimens'
  DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED = 'inventory fulfilled'
  DISBURSER_REQUEST_SPECIMEN_STATUSES = [DISBURSER_REQUEST_SPECIMEN_STATUS_NOT_STARTED, DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_CHECKED, DISBURSER_REQUEST_SPECIMEN_STATUS_INSUFFICIENT_SPECIMENS, DISBURSER_REQUEST_SPECIMEN_STATUS_INVENTORY_FULFILLED]
  DISBURSER_REQUEST_SPECIMEN_STATUSES_SANS_NOT_STARTED = DISBURSER_REQUEST_SPECIMEN_STATUSES - [DISBURSER_REQUEST_SPECIMEN_STATUS_NOT_STARTED]

  DISBURSER_REQUEST_VOTE_STATUS_PENDING_MY_VOTE = 'pending my vote'
  DISBURSER_REQUEST_VOTE_STATUS_APPROVED = 'approved'
  DISBURSER_REQUEST_VOTE_STATUS_DENIED = 'denied'
  DISBURSER_REQUEST_VOTE_STATUSES = [DISBURSER_REQUEST_VOTE_STATUS_PENDING_MY_VOTE, DISBURSER_REQUEST_VOTE_STATUS_APPROVED, DISBURSER_REQUEST_VOTE_STATUS_DENIED]

  scope :search_across_fields, ->(search_token, options={}) do
    if search_token
      search_token.downcase!
    end
    options = { sort_column: 'title', sort_direction: 'asc' }.merge(options)
    s = DisburserRequest
    s = s.joins(:submitter)
    s = s.joins(:repository)
    if search_token
      s = s.where(["lower(title) like ? OR lower(investigator) like ? OR lower(irb_number) like ?", "%#{search_token}%", "%#{search_token}%", "%#{search_token}%"])
    end

    sort = options[:sort_column] + ' ' + options[:sort_direction] + ', disburser_requests.id ASC'

    s = s.nil? ? order(sort) : s.order(sort)

    s
  end

  scope :not_draft, -> do
    where.not(status: DisburserRequest::DISBURSER_REQUEST_STAUTS_DRAFT)
  end

  scope :reviewable, -> do
    where(status: DisburserRequest::DISBURSER_REQUEST_STATUSES_REVIEWABLE)
  end

  scope :by_vote_status, ->(user, vote_status) do
    case vote_status
      when DisburserRequest::DISBURSER_REQUEST_VOTE_STATUS_PENDING_MY_VOTE
        where('NOT EXISTS (SELECT 1 FROM disburser_request_votes WHERE disburser_requests.id = disburser_request_votes.disburser_request_id AND vote IS NOT NULL AND committee_member_user_id = ?)', user.id)
      when DisburserRequest::DISBURSER_REQUEST_VOTE_STATUS_APPROVED
        where('EXISTS (SELECT 1 FROM disburser_request_votes WHERE disburser_requests.id = disburser_request_votes.disburser_request_id AND vote = ? AND committee_member_user_id = ?)', DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, user.id)
      when DisburserRequest::DISBURSER_REQUEST_VOTE_STATUS_DENIED
        where('EXISTS (SELECT 1 FROM disburser_request_votes WHERE disburser_requests.id = disburser_request_votes.disburser_request_id AND vote = ? AND committee_member_user_id = ?)', DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_DENY, user.id)
      else
        where('1=1')
    end
  end

  scope :by_feasibility, ->(feasibility) do
    if !feasibility.nil? && feasibility != ''
      feasibility = Disburser::Utility.to_boolean(feasibility)
      where(feasibility: feasibility)
    end
  end

  scope :by_status, ->(status) do
    if status.present?
     where(status: status)
    end
  end

  scope :by_data_status, ->(data_status) do
    if data_status.present?
     where(data_status: data_status)
    end
  end

  scope :by_specimen_status, ->(specimen_status) do
    if specimen_status.present?
      where(specimen_status: specimen_status)
    end
  end

  scope :by_repository, ->(repository_id) do
    if repository_id.present?
      where(repository_id: repository_id)
    end
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

  def data_status_not_started?
    self.data_status == DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_NOT_STARTED
  end

  def specimen_status_not_started?
    self.specimen_status == DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_NOT_STARTED
  end

  def find_or_initialize_disburser_request_vote(user)
    disburser_request_votes.by_user(user).first || disburser_request_votes.build(committee_member: user)
  end

  def submitted_at
    disburser_reqeust_status = disburser_request_statuses.select { |disburser_request_status| disburser_request_status.status_type == DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS &&  disburser_request_status.status == DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED }.last
    if disburser_reqeust_status.present?
      disburser_reqeust_status.created_at
    end
  end

  def committee_review_at
    disburser_reqeust_status = disburser_request_statuses.select { |disburser_request_status| disburser_request_status.status_type == DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS &&  disburser_request_status.status == DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW }.last
    if disburser_reqeust_status.present?
      disburser_reqeust_status.created_at
    end
  end

  def status_detail(status)
    get_status_detail(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS, status)
  end

  def data_status_detail(status)
    get_status_detail(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_DATA_STATUS, status)
  end

  def specimen_status_detail(status)
    get_status_detail(DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_SPECIMEN_STATUS, status)
  end

  def build_disburser_request_status
    if !self.draft? && self.status_changed?
      disburser_request_statuses.build(status_type: DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_STATUS, status: self.status, user_id: self.status_user.id, comments: self.status_comments)
    end

    if !self.data_status_not_started? && self.data_status_changed?
      disburser_request_statuses.build(status_type: DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_DATA_STATUS, status: self.data_status, user_id: self.status_user.id, comments: self.data_status_comments)
    end

    if !self.specimen_status_not_started? && self.specimen_status_changed?
      disburser_request_statuses.build(status_type: DisburserRequestStatus::DISBURSER_REQUEST_STATUS_TYPE_SPECIMEN_STATUS, status: self.specimen_status, user_id: self.status_user.id, comments: self.specimen_status_comments)
    end
  end

  def specimens?
    disburser_request_details.any?
  end

  def investigator_cancellable?
    [DisburserRequest::DISBURSER_REQUEST_STAUTS_DRAFT, DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED].include?(self.status)
  end

  private
    def set_defaults
      if self.new_record?
        if self.status.blank?
          self.status = DisburserRequest::DISBURSER_REQUEST_STAUTS_DRAFT
        end
        self.data_status = DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_NOT_STARTED
        self.specimen_status = DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_NOT_STARTED

        if self.repository && self.repository.custom_request_form.present?
          self.use_custom_request_form = true
        end
      end
    end

    def get_status_detail(status_type, status)
      disburser_request_statuses.order('id DESC').detect { |disburser_request_status| disburser_request_status.status_type == status_type && disburser_request_status.status == status }
    end
end
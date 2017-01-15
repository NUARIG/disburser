class DisburserRequest < ApplicationRecord
  belongs_to :repository
  belongs_to :submitter, class_name: 'User', foreign_key: :submitter_id
  has_many :disburser_request_details
  has_many :disburser_request_statuses
  accepts_nested_attributes_for :disburser_request_details, reject_if: :all_blank, allow_destroy: true
  validates_presence_of :investigator, :title, :irb_number, :methods_justifications, :cohort_criteria, :data_for_cohort
  validates_associated :disburser_request_details

  mount_uploader :methods_justifications, MethodsJustificationsUploader

  after_initialize :set_defaults
  before_save :build_disburser_request_status
  attr_accessor :status_user

  DISBURSER_REQUEST_STAUTS_DRAFT = 'draft'
  DISBURSER_REQUEST_STATUS_SUBMITTED = 'submitted'
  DISBURSER_REQUEST_STATUSES = [DISBURSER_REQUEST_STAUTS_DRAFT, DISBURSER_REQUEST_STATUS_SUBMITTED]

  scope :search_across_fields, ->(search_token, options={}) do
    if search_token
      search_token.downcase!
    end
    options = { sort_column: 'title', sort_direction: 'asc' }.merge(options)
    s = DisburserRequest
    s = s.joins(:submitter)
    if search_token
      s = where(["lower(title) like ? OR lower(investigator) like ? OR lower(irb_number) like ?", "%#{search_token}%", "%#{search_token}%", "%#{search_token}%"])
    end

    sort = options[:sort_column] + ' ' + options[:sort_direction] + ', disburser_requests.id ASC'
    s = s.nil? ? order(sort) : s.order(sort)

    s
  end

  def mine?(user)
    submitter == user
  end

  def draft?
    self.status == DisburserRequest::DISBURSER_REQUEST_STAUTS_DRAFT
  end

  def build_disburser_request_status
    if disburser_request_statuses.none? { |disburser_request_status| disburser_request_status.status == self.status  } && !self.draft?
      disburser_request_statuses.build(status: self.status, username: self.status_user.username)
    end
  end

  private
    def set_defaults
      if self.new_record?
        if self.status.blank?
          self.status = DisburserRequest::DISBURSER_REQUEST_STAUTS_DRAFT
        end
      end
    end
end
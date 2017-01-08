class DisburserRequest < ApplicationRecord
  belongs_to :repository
  belongs_to :submitter, class_name: 'User', foreign_key: :submitter_id
  has_many :disburser_request_details
  accepts_nested_attributes_for :disburser_request_details, reject_if: :all_blank, allow_destroy: true
  validates_presence_of :investigator, :title, :irb_number, :methods_justifications, :cohort_criteria, :data_for_cohort
  mount_uploader :methods_justifications, MethodsJustificationsUploader

  after_initialize :set_defaults

  DISBURSER_REQUEST_STAUTS_INITIAL = 'initial'
  DISBURSER_REQUEST_STATUS_SUBMITTED = 'submitted'
  DISBURSER_REQUEST_STATUSES = [DISBURSER_REQUEST_STAUTS_INITIAL, DISBURSER_REQUEST_STATUS_SUBMITTED]

  DISBURSER_REQUEST_RESOURCE_STAUTS_OPEN = 'open'
  DISBURSER_REQUEST_RESOURCE_STAUTS_CLOSED = 'closed'
  DISBURSER_REQUEST_RESOURCE_STATUSES = [DISBURSER_REQUEST_RESOURCE_STAUTS_OPEN, DISBURSER_REQUEST_RESOURCE_STAUTS_CLOSED]

  scope :search_across_fields, ->(search_token, options={}) do
    if search_token
      search_token.downcase!
    end
    options = { sort_column: 'name', sort_direction: 'asc' }.merge(options)

    if search_token
      s = where(["lower(title) like ?", "%#{search_token}%"])
    end

    sort = options[:sort_column] + ' ' + options[:sort_direction] + ', disburser_requests.id ASC'
    s = s.nil? ? order(sort) : s.order(sort)

    s
  end

  private
    def set_defaults
      self.status = DisburserRequest::DISBURSER_REQUEST_STAUTS_INITIAL
      self.data_status = DisburserRequest::DISBURSER_REQUEST_RESOURCE_STAUTS_OPEN
      if self.specimens
        self.specimens_status = DisburserRequest::DISBURSER_REQUEST_RESOURCE_STAUTS_OPEN
      end
    end
end
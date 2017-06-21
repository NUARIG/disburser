class Repository < ApplicationRecord
  has_paper_trail
  has_many :repository_users
  has_many :users, through: :repository_users
  accepts_nested_attributes_for :repository_users, reject_if: :all_blank, allow_destroy: true
  has_many :specimen_types, -> { order(:name) }
  accepts_nested_attributes_for :specimen_types, allow_destroy: true
  has_many :disburser_requests

  mount_uploader :irb_template, IrbTemplateUploader
  mount_uploader :data_dictionary, DataDictionaryUploader
  mount_uploader :custom_request_form, CustomRequestFormUploader

  validates_presence_of :name
  validates_size_of :irb_template, maximum: 10.megabytes, message: 'must be less than 10MB'
  validates_size_of :data_dictionary, maximum: 10.megabytes, message: 'must be less than 10MB'
  validates_size_of :custom_request_form, maximum: 10.megabytes, message: 'must be less than 10MB'

  after_destroy :remove_irb_template!, :remove_data_dictionary!, :remove_custom_request_form!

  scope :search_across_fields, ->(search_token, options={}) do
    if search_token
      search_token.downcase!
    end
    options = { sort_column: 'name', sort_direction: 'asc' }.merge(options)

    if search_token
      s = where(["lower(name) like ?", "%#{search_token}%"])
    end

    sort = options[:sort_column] + ' ' + options[:sort_direction] + ', repositories.id ASC'
    s = s.nil? ? order(sort) : s.order(sort)

    s
  end

  scope :is_public, -> do
    where(public: true)
  end

  def repository_administrator?(user)
    repository_users.where(user_id: user.id, administrator: true).any?
  end

  def committee_member?(user)
    repository_users.where(user_id: user.id, committee: true).any?
  end

  def repository_coordinator?(user)
    repository_users.where('user_id = ? AND (data_coordinator = ? OR specimen_coordinator = ?)', user.id, true, true).any?
  end

  def data_coordinator?(user)
    repository_users.where('user_id = ? AND data_coordinator = ?', user.id, true).any?
  end

  def specimen_coordinator?(user)
    repository_users.where('user_id = ? AND specimen_coordinator = ?', user.id, true).any?
  end

  def repository_administrators(options={})
    options.reverse_merge!(include_system_administrtors: false)
    administrators = repository_users.where(administrator: true).map(&:user)
    if options[:include_system_administrtors]
      administrators.concat(User.where(system_administrator: true))
    end
    administrators.uniq!
    administrators
  end

  def committee_members
    cm = repository_users.where(committee: true).map(&:user)
    cm
  end

  def specimen_coordinators
    sc = repository_users.where(specimen_coordinator: true).map(&:user)
    sc
  end

  def data_coordinators
    dc = repository_users.where(data_coordinator: true).map(&:user)
    dc
  end

  def unpublished_content?
    (general_content != general_content_published) || (data_content != data_content_published) || (specimen_content != specimen_content_published)
  end

  def publish_content!
    self.general_content_published = self.general_content
    self.data_content_published = self.data_content
    self.specimen_content_published = self.specimen_content
    save!
  end
end
class Repository < ApplicationRecord
  has_many :repository_users
  has_many :users, through: :repository_users
  accepts_nested_attributes_for :repository_users, reject_if: :all_blank, allow_destroy: true
  has_many :specimen_types, -> { order(:name) }
  accepts_nested_attributes_for :specimen_types, reject_if: :all_blank, allow_destroy: true
  has_many :disburser_requests

  mount_uploader :irb_template, IrbTemplateUploader
  mount_uploader :data_dictionary, DataDictionaryUploader

  validates_presence_of :name
  validates_size_of :irb_template, maximum: 10.megabytes, message: 'must be less than 10MB'
  validates_size_of :data_dictionary, maximum: 10.megabytes, message: 'must be less than 10MB'

  after_destroy :remove_irb_template!, :remove_data_dictionary!

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

  def repository_administator?(user)
    repository_users.where(administrator: true, user_id: user.id).any?
  end
end
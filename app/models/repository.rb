class Repository < ApplicationRecord
  has_many :repository_users
  accepts_nested_attributes_for :repository_users, reject_if: :all_blank, allow_destroy: true
  has_many :specimen_types, -> { order(:name) }
  accepts_nested_attributes_for :specimen_types, reject_if: :all_blank, allow_destroy: true

  validates_presence_of :name

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
end
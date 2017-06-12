class RepositoryUser < ApplicationRecord
  has_paper_trail
  belongs_to :user
  belongs_to :repository
  attr_accessor :username

  validates_presence_of :username, on: :create

  before_validation :init_user, on: :create

  #Class Methods
  scope :search_across_fields, ->(search_token, options={}) do
    if search_token
      search_token.downcase!
    end
    options = { sort_column: 'users.username', sort_direction: 'asc' }.merge(options)

    s = joins(:user)

    if search_token
      s = s.where(["lower(users.username) like ? OR lower(users.email) like ? OR lower(users.first_name) like ? OR lower(users.last_name) like ?", "%#{search_token}%", "%#{search_token}%", "%#{search_token}%", "%#{search_token}%"])
    end

    sort = options[:sort_column] + ' ' + options[:sort_direction] + ', repository_users.id ASC'
    s = s.nil? ? order(sort) : s.order(sort)

    s
  end

  #Instance Methods
  def init_user
    u = User.where(username: self.username).first

    if !self.username.blank? && u.blank?
      u = NorthwesternUser.new(username: self.username)
      u.hydrate_from_ldap
      u.save!
    end

    self.user = u
  end
end

class User < ApplicationRecord
  has_many :repository_users
  has_many :repositories, through: :repository_users
  has_many :disburser_requests, foreign_key: :submitter_id

  validates :email, uniqueness: true

  USER_TYPE_NORTHWESTERN = 'Northwestern'
  USER_TYPE_EXTERNAL = 'External'
  USER_TYPES = [USER_TYPE_NORTHWESTERN, USER_TYPE_EXTERNAL]

  def admin?
    self.system_administrator || repository_administrator?
  end

  def committee?
    repository_users.any? { |repository_user| repository_user.committee }
  end

  def repository_administrator?
    repository_users.any? { |repository_user| repository_user.administrator }
  end

  def data_coordinator?
    repository_users.any? { |repository_user| repository_user.data_coordinator }
  end

  def specimen_coordinator?
    repository_users.any? { |repository_user| repository_user.specimen_coordinator }
  end

  def repository_coordinator?
    repository_users.any? { |repository_user| repository_user.specimen_coordinator ||  repository_user.data_coordinator }
  end

  def full_name
    [first_name.titleize, last_name.titleize].reject { |n| n.nil? or n.blank? }.join(' ')
  end

  def data_coordinator_disbursr_requests(options = {})
    cdr = DisburserRequest.joins(:submitter).joins(:repository).where(repository_id: repository_users.where('data_coordinator = ?', true).map(&:repository_id))

    if options[:status].present?
      cdr = cdr.by_status(options[:status])
    end

    if options[:data_status].present?
      cdr = cdr.by_data_status(options[:data_status])
    end

    if options[:specimen_status].present?
      cdr = cdr.by_specimen_status(options[:specimen_status])
    end

    cdr.not_draft
  end

  def specimen_coordinator_disbursr_requests(options = {})
    sdr = DisburserRequest.joins(:submitter).joins(:repository).where(repository_id: repository_users.where('specimen_coordinator = ?', true).map(&:repository_id))

    if options[:status].present?
      sdr = sdr.by_status(options[:status])
    end

    if options[:data_status].present?
      sdr = sdr.by_data_status(options[:data_status])
    end

    if options[:specimen_status].present?
      sdr = sdr.by_specimen_status(options[:specimen_status])
    end

    sdr.not_draft
  end

  def admin_disbursr_requests
    if self.system_administrator
      adr = DisburserRequest
    else
      adr = DisburserRequest.where(repository_id: repository_users.where('administrator = ?', true).map(&:repository_id))
    end
    adr.not_draft
  end

  def committee_disburser_requests(options = {})
    cdr = DisburserRequest.joins(:submitter).joins(:repository).where(repository_id: repository_users.where('committee = ?', true).map(&:repository_id))

    if options[:status].present?
      cdr = cdr.by_status(options[:status])
    end

    cdr.reviewable.by_feasibility(false)
  end

  def self.search(search_token, repository = nil)
    users = NorthwesternUser.search(search_token, repository)
    users.concat(ExternalUser.search(search_token, repository))
    users
  end
end
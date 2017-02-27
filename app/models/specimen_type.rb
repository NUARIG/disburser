class SpecimenType < ApplicationRecord
  has_paper_trail
  belongs_to :repository
  has_many :disburser_request_details, dependent: :restrict_with_exception

  validates_presence_of :name
end
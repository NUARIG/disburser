class SpecimenType < ApplicationRecord
  belongs_to :repository

  validates_presence_of :name
end
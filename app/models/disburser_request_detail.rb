class DisburserRequestDetail < ApplicationRecord
  belongs_to :disburser_request
  validates_presence_of :quantity
end
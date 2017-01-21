class DisburserRequestStatus < ApplicationRecord
  belongs_to :disburser_request, required: false
  belongs_to :user
end
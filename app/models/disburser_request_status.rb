class DisburserRequestStatus < ApplicationRecord
  belongs_to :disburser_request, required: false
end
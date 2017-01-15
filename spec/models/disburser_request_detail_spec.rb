require 'rails_helper'
require 'active_support'

RSpec.describe DisburserRequestDetail, type: :model do
  it { should belong_to :disburser_request }
  it { should belong_to :specimen_type }
  it { should validate_presence_of :quantity }
  it { should validate_presence_of :specimen_type_id }
end
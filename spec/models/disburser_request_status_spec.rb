require 'rails_helper'
require 'active_support'

RSpec.describe DisburserRequestStatus, type: :model do
  it { should belong_to :disburser_request }
   it { should belong_to :user }
end
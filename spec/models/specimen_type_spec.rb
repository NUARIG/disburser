require 'rails_helper'
require 'active_support'

RSpec.describe SpecimenType, type: :model do
  it { should belong_to :repository }
  it { should validate_presence_of :name }
end
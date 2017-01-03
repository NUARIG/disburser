require 'rails_helper'
require 'active_support'

RSpec.describe Repository, type: :model do
  it { should have_many :repository_users }
  it { should have_many :specimen_types }
  it { should have_many :users }
  it { should validate_presence_of :name }

  it 'can search accross fields (by name)', focus: false do
    repository_1 = FactoryGirl.create(:repository, name: 'Moomins')
    repository_2 = FactoryGirl.create(:repository, name: 'Peanuts')
    expect(Repository.search_across_fields('Moomin')).to match_array([repository_1])
  end

  it 'can search accross fields (by accession number) case insensitively', focus: false do
    repository_1 = FactoryGirl.create(:repository, name: 'Moomins')
    repository_2 = FactoryGirl.create(:repository, name: 'Peanuts')
    expect(Repository.search_across_fields('MOOMIN')).to match_array([repository_1])
  end

  it 'can search accross fields (and sort ascending/descending by a passed in column)', focus: false do
    repository_1 = FactoryGirl.create(:repository, name: 'Moomins', data: true, specimens: false)
    repository_2 = FactoryGirl.create(:repository, name: 'Peanuts', data: false, specimens: true)
    expect(Repository.search_across_fields(nil, { sort_column: 'name', sort_direction: 'asc' })).to eq([repository_1, repository_2])
    expect(Repository.search_across_fields(nil, { sort_column: 'name', sort_direction: 'desc' })).to eq([repository_2, repository_1])

    expect(Repository.search_across_fields(nil, { sort_column: 'data', sort_direction: 'asc' })).to eq([repository_2, repository_1])
    expect(Repository.search_across_fields(nil, { sort_column: 'data', sort_direction: 'desc' })).to eq([repository_1, repository_2])

    expect(Repository.search_across_fields(nil, { sort_column: 'specimens', sort_direction: 'asc' })).to eq([repository_1, repository_2])
    expect(Repository.search_across_fields(nil, { sort_column: 'specimens', sort_direction: 'desc' })).to eq([repository_2, repository_1])
  end
end
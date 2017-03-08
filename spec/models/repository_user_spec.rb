require 'rails_helper'
require 'active_support'

RSpec.describe RepositoryUser, type: :model do
  it { should belong_to :user }
  it { should belong_to :repository }
  it { should validate_presence_of :username }

  before(:each) do
    @repository = FactoryGirl.build(:repository, name: 'Test Repository')
  end

  describe 'creating repository users' do
    it 'creates and initializes a user upon creation of a reposiotry user if the user does not already exist', focus: false do
      username = 'moominpapa'
      first_name = 'Mominpapa'
      last_name = 'Moomin'
      email = 'moominpapa@moomin.com'
      moominpapa = { username: username, first_name: first_name, last_name: last_name, email: email}
      allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(moominpapa)
      repository_user = FactoryGirl.create(:repository_user, repository: @repository, username: username)
      user = User.where(username: username).first
      repository_user.reload
      expect(repository_user.user.username).to eq(user.username)
      expect(repository_user.user.first_name).to eq(user.first_name)
      expect(repository_user.user.last_name).to eq(user.last_name)
      expect(repository_user.user.email).to eq(user.email)
    end

    it 'reuses a user upon creation of a repository user if the user already exists', focus: false do
      username = 'moominpapa'
      first_name = 'Mominpapa'
      last_name = 'Moomin'
      email = 'moominpapa@moomin.com'
      moominpapa = { username: username, first_name: first_name, last_name: last_name, email: email}
      allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(moominpapa)
      repository_user = FactoryGirl.create(:repository_user, repository: @repository, username: username)
      user = User.where(username: username).first
      repository_user.reload
      expect(repository_user.user.username).to eq(user.username)
      expect(repository_user.user.first_name).to eq(user.first_name)
      expect(repository_user.user.last_name).to eq(user.last_name)
      expect(repository_user.user.email).to eq(user.email)
      repository_2 = FactoryGirl.build(:repository, name: 'Test 2 Repository')
      repository_user_2 = FactoryGirl.create(:repository_user, repository: repository_2, username: username)
      user = User.where(username: username).first
      repository_user_2.reload
      expect(repository_user_2.user.username).to eq(user.username)
      expect(repository_user_2.user.first_name).to eq(user.first_name)
      expect(repository_user_2.user.last_name).to eq(user.last_name)
      expect(repository_user_2.user.email).to eq(user.email)
      expect(User.where(username: username).count).to eq(1)
    end
  end

  describe 'searching across fields' do
    before(:each) do
      username = 'moominpapa1'
      first_name = 'Moominpapa2'
      last_name = 'Moomin4'
      email = 'moominpapa3@moomin.com'
      moominpapa = { username: username, first_name: first_name, last_name: last_name, email: email}
      allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(moominpapa)
      @repository_user_moominpapa = FactoryGirl.create(:repository_user, repository: @repository, username: username)

      username = 'moominmmama1'
      first_name = 'Moominmmama2'
      last_name = 'Moomin5'
      email = 'moominmmama3@moomin.com'
      moominmmama = { username: username, first_name: first_name, last_name: last_name, email: email}
      allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(moominmmama)
      @repository_user_moominmmama = FactoryGirl.create(:repository_user, repository: @repository, username: username)
    end

    it 'can search accross fields (by username) case insensitively', focus: false do
      expect(RepositoryUser.search_across_fields('MAMA1')).to match_array([@repository_user_moominmmama])
      expect(RepositoryUser.search_across_fields('MOOMIN')).to match_array([@repository_user_moominpapa, @repository_user_moominmmama])
    end

    it 'can search accross fields (by first name) case insensitively', focus: false do
      expect(RepositoryUser.search_across_fields('mama2')).to match_array([@repository_user_moominmmama])
      expect(RepositoryUser.search_across_fields('MOOMIN')).to match_array([@repository_user_moominpapa, @repository_user_moominmmama])
    end

    it 'can search accross fields (by last name) case insensitively', focus: false do
      expect(RepositoryUser.search_across_fields('moomin5')).to match_array([@repository_user_moominmmama])
      expect(RepositoryUser.search_across_fields('MOOMIN')).to match_array([@repository_user_moominpapa, @repository_user_moominmmama])
    end

    it 'can search accross fields (by email) case insensitively', focus: false do
      expect(RepositoryUser.search_across_fields('MAMA3')).to match_array([@repository_user_moominmmama])
      expect(RepositoryUser.search_across_fields('MOOMIN')).to match_array([@repository_user_moominpapa, @repository_user_moominmmama])
    end

    it 'can search accross fields (and sort ascending/descending by a passed in column)', focus: false do
      expect(RepositoryUser.search_across_fields(nil, { sort_column: 'username', sort_direction: 'asc' })).to eq([@repository_user_moominmmama, @repository_user_moominpapa])
      expect(RepositoryUser.search_across_fields(nil, { sort_column: 'username', sort_direction: 'desc' })).to eq([@repository_user_moominpapa, @repository_user_moominmmama])

      expect(RepositoryUser.search_across_fields(nil, { sort_column: 'first_name', sort_direction: 'asc' })).to eq([@repository_user_moominmmama, @repository_user_moominpapa])
      expect(RepositoryUser.search_across_fields(nil, { sort_column: 'first_name', sort_direction: 'desc' })).to eq([@repository_user_moominpapa, @repository_user_moominmmama])

      expect(RepositoryUser.search_across_fields(nil, { sort_column: 'last_name', sort_direction: 'asc' })).to eq([@repository_user_moominpapa, @repository_user_moominmmama])
      expect(RepositoryUser.search_across_fields(nil, { sort_column: 'last_name', sort_direction: 'desc' })).to eq([@repository_user_moominmmama, @repository_user_moominpapa])

      expect(RepositoryUser.search_across_fields(nil, { sort_column: 'email', sort_direction: 'asc' })).to eq([@repository_user_moominmmama, @repository_user_moominpapa])
      expect(RepositoryUser.search_across_fields(nil, { sort_column: 'email', sort_direction: 'desc' })).to eq([@repository_user_moominpapa, @repository_user_moominmmama])
    end
  end
end
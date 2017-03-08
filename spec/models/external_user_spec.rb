require 'rails_helper'
require 'active_support'

RSpec.describe ExternalUser, type: :model do
  it { should validate_presence_of :first_name }
  it { should validate_presence_of :last_name }

  before(:each) do
    @moomin_repository = FactoryGirl.create(:repository, name: 'Moomins')
    @white_sox_repository = FactoryGirl.create(:repository, name: 'White Sox')
    @moomintroll_user = FactoryGirl.build(:external_user, email: 'moomintroll@moomin.com',  username: 'moomintroll@moomin.com', first_name: 'Moomintroll', last_name: 'Moomin')
    @moomintroll_user.save!
    @moominpapa_user = FactoryGirl.build(:external_user, email: 'moominpapa@moomin.com',  username: 'moominpapa@moomin.com', first_name: 'Moominpapa', last_name: 'Moomin')
    @moominpapa_user.save!
    @paul_user = FactoryGirl.build(:external_user, email: 'paulie@whitesox.com',  username: 'paulie@whitesox.com', first_name: 'Paul', last_name: 'Konerko')
    @paul_user.save!
    @nellie_user = FactoryGirl.build(:external_user, email: 'nellie@whitesox.com', username: 'nellie@whitesox.com', first_name: 'Nellie', last_name: 'Fox')
    @nellie_user.save!
  end

  it 'defaults the username to email', focus: false do
    expect(ExternalUser.new(first_name: @moomintroll_user.first_name, last_name: @moomintroll_user.last_name, email: @moomintroll_user.email).username).to eq(@moomintroll_user.email)
  end

  it 'can search by a token', focus: false do
    expect(ExternalUser.search('Moomin')).to match_array([{ username: @moomintroll_user.username, first_name: @moomintroll_user.first_name, last_name: @moomintroll_user.last_name, email: @moomintroll_user.email }, { username: @moominpapa_user.username, first_name: @moominpapa_user.first_name, last_name: @moominpapa_user.last_name, email: @moominpapa_user.email }])
  end

  it 'can search by a token (case insensitively)', focus: false do
    expect(ExternalUser.search('MOOMIN')).to match_array([{ username: @moomintroll_user.username, first_name: @moomintroll_user.first_name, last_name: @moomintroll_user.last_name, email: @moomintroll_user.email }, { username: @moominpapa_user.username, first_name: @moominpapa_user.first_name, last_name: @moominpapa_user.last_name, email: @moominpapa_user.email }])
  end

  it 'can search ldap by multiple tokens and filter the results', focus: false do
    expect(ExternalUser.search('moomin moominpapa')).to match_array([{ username: @moominpapa_user.username, first_name: @moominpapa_user.first_name, last_name: @moominpapa_user.last_name, email: @moominpapa_user.email }])
  end

  it 'can search ldap by multiple tokens and filter the results (case insensitively)', focus: false do
    expect(ExternalUser.search('moomin moominpapa')).to match_array([{ username: @moominpapa_user.username, first_name: @moominpapa_user.first_name, last_name: @moominpapa_user.last_name, email: @moominpapa_user.email }])
  end

  it 'can search by a token and filter the results to not include existing users', focus: false do
    expect(ExternalUser.search('Moomin')).to match_array([{ username: @moomintroll_user.username, first_name: @moomintroll_user.first_name, last_name: @moomintroll_user.last_name, email: @moomintroll_user.email }, { username: @moominpapa_user.username, first_name: @moominpapa_user.first_name, last_name: @moominpapa_user.last_name, email: @moominpapa_user.email }])
    FactoryGirl.create(:repository_user, user: @moomintroll_user, repository: @moomin_repository, username: @moomintroll_user.username)
    expect(ExternalUser.search('Moomin', @moomin_repository)).to match_array([{ username: @moominpapa_user.username, first_name: @moominpapa_user.first_name, last_name: @moominpapa_user.last_name, email: @moominpapa_user.email }])
  end
end
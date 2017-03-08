require 'rails_helper'
describe RepositoryUsersController, type: :request do
  before(:each) do
    @repository_moomin = FactoryGirl.create(:repository, name: 'Moomins')
    @paul_user = FactoryGirl.create(:northwestern_user, email: 'paulie@whitesox.com', username: 'pkonerko', first_name: 'Paul', last_name: 'Konerko')
  end

  describe 'regular user' do
    before(:each) do
      sign_in @paul_user
    end

    it 'should deny access to index of repository users', focus: false do
      get repository_repository_users_url(@repository_moomin)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access initiate a new repository user', focus: false do
      get new_repository_repository_user_url(@repository_moomin)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to create a repository user', focus: false do
      post repository_repository_users_url(@repository_moomin), params: { format: :js, repository_user: { username: 'moomin', administrator: true, committee: true, specimen_coordinator: true, data_coordinator: true } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to edit a repository user', focus: false do
      moominpapa = { username: 'moominpapa', first_name: 'Moominpapa', last_name: 'Moomin', email: 'moominpapa@moomin.com'}
      allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(moominpapa)
      repository_user = FactoryGirl.create(:repository_user, repository: @repository_moomin, username: moominpapa[:username])
      get edit_repository_repository_user_url(@repository_moomin, repository_user)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to update a repository user', focus: false do
      moominpapa = { username: 'moominpapa', first_name: 'Moominpapa', last_name: 'Moomin', email: 'moominpapa@moomin.com'}
      allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(moominpapa)
      repository_user = FactoryGirl.create(:repository_user, repository: @repository_moomin, username: moominpapa[:username])
      put repository_repository_user_url(@repository_moomin, repository_user), params: { format: :js, repository_user: { administrator: true, committee: true, specimen_coordinator: true, data_coordinator: true } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end
  end

  describe 'system administrator user' do
    before(:each) do
      @paul_user.system_administrator = true
      @paul_user.save
      sign_in @paul_user
    end

    it 'should allow access to index of repository users', focus: false do
      get repository_repository_users_url(@repository_moomin)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to initiate a new repository user', focus: false do
      get new_repository_repository_user_url(@repository_moomin)
      expect(response).to have_http_status(:success)
    end

    it 'should allow to create a repository user', focus: false  do
      moominpapa = { username: 'moominpapa', first_name: 'Moominpapa', last_name: 'Moomin', email: 'moominpapa@moomin.com'}
      allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(moominpapa)
      repository_user = FactoryGirl.create(:repository_user, repository: @repository_moomin, username: moominpapa[:username])
      post repository_repository_users_url(@repository_moomin), params: { format: :js, repository_user: { username: moominpapa[:username], administrator: true, committee: true, specimen_coordinator: true, data_coordinator: true } }
      expect(response).to have_http_status(:no_content)
    end

    it 'should allow access to edit a repository user', focus: false do
      moominpapa = { username: 'moominpapa', first_name: 'Moominpapa', last_name: 'Moomin', email: 'moominpapa@moomin.com'}
      allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(moominpapa)
      repository_user = FactoryGirl.create(:repository_user, repository: @repository_moomin, username: moominpapa[:username])
      get edit_repository_repository_user_url(@repository_moomin, repository_user)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to update a repository user', focus: false do
      moominpapa = { username: 'moominpapa', first_name: 'Moominpapa', last_name: 'Moomin', email: 'moominpapa@moomin.com'}
      allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(moominpapa)
      repository_user = FactoryGirl.create(:repository_user, repository: @repository_moomin, username: moominpapa[:username])
      put repository_repository_user_url(@repository_moomin, repository_user), params: { format: :js, repository_user: { administrator: true, committee: true, specimen_coordinator: true, data_coordinator: true } }
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'repository administrator user' do
    before(:each) do
      @harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com', administator: true,  committee: false, specimen_coordinator: false, data_coordinator: false }
      allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(@harold)
      @repository_moomin.repository_users.build(username: @harold[:username], administrator: true)
      @repository_moomin.save!
      @harold_user = User.where(username: @harold[:username]).first
      sign_in @harold_user
    end

    it 'should allow access to index of repository users', focus: false do
      get repository_repository_users_url(@repository_moomin)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to initiate a new repository user', focus: false do
      get new_repository_repository_user_url(@repository_moomin)
      expect(response).to have_http_status(:success)
    end

    it 'should allow to create a repository user', focus: false  do
      moominpapa = { username: 'moominpapa', first_name: 'Moominpapa', last_name: 'Moomin', email: 'moominpapa@moomin.com'}
      allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(moominpapa)
      repository_user = FactoryGirl.create(:repository_user, repository: @repository_moomin, username: moominpapa[:username])
      post repository_repository_users_url(@repository_moomin), params: { format: :js, repository_user: { username: moominpapa[:username], administrator: true, committee: true, specimen_coordinator: true, data_coordinator: true } }
      expect(response).to have_http_status(:no_content)
    end

    it 'should allow access to edit a repository user', focus: false do
      moominpapa = { username: 'moominpapa', first_name: 'Moominpapa', last_name: 'Moomin', email: 'moominpapa@moomin.com'}
      allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(moominpapa)
      repository_user = FactoryGirl.create(:repository_user, repository: @repository_moomin, username: moominpapa[:username])
      get edit_repository_repository_user_url(@repository_moomin, repository_user)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to update a repository user', focus: false do
      moominpapa = { username: 'moominpapa', first_name: 'Moominpapa', last_name: 'Moomin', email: 'moominpapa@moomin.com'}
      allow(NorthwesternUser).to receive(:find_ldap_entry_by_username).and_return(moominpapa)
      repository_user = FactoryGirl.create(:repository_user, repository: @repository_moomin, username: moominpapa[:username])
      put repository_repository_user_url(@repository_moomin, repository_user), params: { format: :js, repository_user: { administrator: true, committee: true, specimen_coordinator: true, data_coordinator: true } }
      expect(response).to have_http_status(:no_content)
    end
  end
end
require 'rails_helper'
describe RepositoriesController, type: :request do
  before(:each) do
    @repository_moomin = FactoryGirl.create(:repository, name: 'Moomins')
    @paul_user = FactoryGirl.create(:user, email: 'paulie@whitesox.com', username: 'pkonerko', first_name: 'Paul', last_name: 'Konerko')
  end

  describe 'regular user' do
    before(:each) do
      sign_in @paul_user
    end

    it 'should deny access to index of repositories', focus: false do
      get repositories_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access initiate a new repository', focus: false do
      get new_repository_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to create a repository', focus: false do
      post repositories_url, params: { repository: { name: 'White Sox' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to show a repository if it is not public', focus: false do
      get repository_url(@repository_moomin.id )
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to show a repository is public', focus: false do
      @repository_moomin.public = true
      @repository_moomin.save
      get repository_url(@repository_moomin.id )
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to edit a repository', focus: false do
      get edit_repository_url(@repository_moomin)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to update a repository', focus: false do
      put repository_url(@repository_moomin), params: { repository: { name: 'White Sox' } }
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

    it 'should allow access to index of repositories', focus: false do
      get repositories_url
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to initiate a new repository', focus: false do
      get new_repository_url
      expect(response).to have_http_status(:success)
    end

    it 'should allow to create a repository', focus: false do
      post repositories_url, params: { repository: { name: 'White Sox' } }
      expect(response).to have_http_status(:found)
      expect(flash[:success]).to eq('You have successfully created a repository.')
    end

    it 'should deny access to show a repository if it is not public', focus: false do
      get repository_url(@repository_moomin.id )
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to show a repository is public', focus: false do
      @repository_moomin.public = true
      @repository_moomin.save
      get repository_url(@repository_moomin.id )
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to edit a repository', focus: false do
      get edit_repository_url(@repository_moomin)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to update a repository', focus: false do
      put repository_url(@repository_moomin), params: { repository: { name: 'White Sox' } }
      expect(response).to have_http_status(:found)
      expect(flash[:success]).to eq('You have successfully updated a repository.')
    end
  end

  describe 'repository administrator user' do
    before(:each) do
      @harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com', administator: true,  committee: false, specimen_coordinator: false, data_coordinator: false }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold)
      @repository_moomin.repository_users.build(username: @harold[:username], administrator: true)
      @repository_moomin.save!
      @harold_user = User.where(username: @harold[:username]).first
      sign_in @harold_user
    end

    it 'should allow access to index of repositories', focus: false do
      get repositories_url
      expect(response).to have_http_status(:success)
    end

    it 'should deny access initiate a new repository', focus: false do
      get new_repository_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to create a repository', focus: false do
      post repositories_url, params: { repository: { name: 'White Sox' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to show a repository if it is not public', focus: false do
      get repository_url(@repository_moomin.id )
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to show a repository is public', focus: false do
      @repository_moomin.public = true
      @repository_moomin.save
      get repository_url(@repository_moomin.id )
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to edit a repository', focus: false do
      get edit_repository_url(@repository_moomin)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to update a repository', focus: false do
      put repository_url(@repository_moomin), params: { repository: { name: 'White Sox' } }
      expect(response).to have_http_status(:found)
      expect(flash[:success]).to eq('You have successfully updated a repository.')
    end
  end
end
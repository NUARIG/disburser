require 'rails_helper'
describe RepositoriesController, type: :request do
  before(:each) do
    @moomin_repository = FactoryGirl.create(:repository, name: 'Moomins')
    @paul_user = FactoryGirl.create(:northwestern_user, email: 'paulie@whitesox.com', username: 'pkonerko', first_name: 'Paul', last_name: 'Konerko')
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
      get repository_url(@moomin_repository.id )
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should allow access to show a repository is public', focus: false do
      @moomin_repository.public = true
      @moomin_repository.save
      get repository_url(@moomin_repository.id )
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to edit a repository', focus: false do
      get edit_repository_url(@moomin_repository)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to update a repository', focus: false do
      put repository_url(@moomin_repository), params: { repository: { name: 'White Sox' } }
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

    it 'should allow access to show a repository even if it is not public', focus: false do
      get repository_url(@moomin_repository.id )
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to show a repository is public', focus: false do
      @moomin_repository.public = true
      @moomin_repository.save
      get repository_url(@moomin_repository.id )
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to edit a repository', focus: false do
      get edit_repository_url(@moomin_repository)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to update a repository', focus: false do
      put repository_url(@moomin_repository), params: { repository: { name: 'White Sox' } }
      expect(response).to have_http_status(:found)
      expect(flash[:success]).to eq('You have successfully updated a repository.')
    end
  end

  describe 'repository administrator user' do
    before(:each) do
      @moomin_repository.repository_users.build(username: @paul_user.username, administrator: true)
      @moomin_repository.save!

      sign_in @paul_user
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

    it 'should allow access to show a repository even if it is not public', focus: false do
      get repository_url(@moomin_repository.id )
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to show a repository is public', focus: false do
      @moomin_repository.public = true
      @moomin_repository.save
      get repository_url(@moomin_repository.id )
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to edit a repository', focus: false do
      get edit_repository_url(@moomin_repository)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to update a repository', focus: false do
      put repository_url(@moomin_repository), params: { repository: { name: 'White Sox' } }
      expect(response).to have_http_status(:found)
      expect(flash[:success]).to eq('You have successfully updated a repository.')
    end
  end
end
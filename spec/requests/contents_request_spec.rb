require 'rails_helper'
describe ContentsController, type: :request do
  before(:each) do
    @moomin_repository = FactoryGirl.create(:repository, name: 'Moomins')
    @paul_user = FactoryGirl.create(:northwestern_user, email: 'paulie@whitesox.com', username: 'pkonerko', first_name: 'Paul', last_name: 'Konerko')
  end

  describe 'regular user' do
    before(:each) do
      sign_in @paul_user
    end

    it 'should deny access to edit repository content', focus: false do
      get edit_repository_content_url(@moomin_repository)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to update a repository content', focus: false do
      put repository_content_url(@moomin_repository), params: { repository: { data_content: 'Foo', specimen_content: 'Bar' } }
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

    it 'should allow access to edit repository content', focus: false do
      get edit_repository_content_url(@moomin_repository)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to update repository content', focus: false do
      put repository_content_url(@moomin_repository), params: { repository: { data_content: 'Foo', specimen_content: 'Bar' } }
      expect(response).to have_http_status(:found)
      expect(flash[:success]).to eq('You have successfully updated repository content.')
    end
  end

  describe 'repository administrator user' do
    before(:each) do
      @moomin_repository.repository_users.build(username: @paul_user.username, administrator: true)
      @moomin_repository.save!

      sign_in @paul_user
    end

    it 'should allow access to edit repository content', focus: false do
      get edit_repository_content_url(@moomin_repository)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to update repository content', focus: false do
      put repository_content_url(@moomin_repository), params: { repository: { data_content: 'Foo', specimen_content: 'Bar' } }
      expect(response).to have_http_status(:found)
      expect(flash[:success]).to eq('You have successfully updated repository content.')
    end
  end
end
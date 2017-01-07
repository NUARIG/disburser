require 'rails_helper'
describe ContentsController, type: :request do
  before(:each) do
    @repository_moomin = FactoryGirl.create(:repository, name: 'Moomins', data: true, specimens: false)
    @paul_user = FactoryGirl.create(:user, email: 'paulie@whitesox.com', username: 'pkonerko', first_name: 'Paul', last_name: 'Konerko')
  end

  describe 'regular user' do
    before(:each) do
      sign_in @paul_user
    end

    it 'should deny access to edit repository content', focus: false do
      get edit_repository_content_url(@repository_moomin)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to update a repository content', focus: false do
      put repository_content_url(@repository_moomin), params: { repository: { data_content: 'Foo', specimen_content: 'Bar' } }
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
      get edit_repository_content_url(@repository_moomin)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to update repository content', focus: false do
      put repository_content_url(@repository_moomin), params: { repository: { data_content: 'Foo', specimen_content: 'Bar' } }
      expect(response).to have_http_status(:found)
      expect(flash[:success]).to eq('You have successfully updated repository content.')
    end
  end

  describe 'repository administrator user' do
    before(:each) do
      @harold = { username: 'hbaines', first_name: 'Harold', last_name: 'Baines', email: 'hbaines@whitesox.com', administator: true,  committee: false, specimen_resource: false, data_resource: false }
      allow(User).to receive(:find_ldap_entry_by_username).and_return(@harold)
      @repository_moomin.repository_users.build(username: @harold[:username], administrator: true)
      @repository_moomin.save!
      @harold_user = User.where(username: @harold[:username]).first
      sign_in @harold_user
    end

    it 'should allow access to edit repository content', focus: false do
      get edit_repository_content_url(@repository_moomin)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to update repository content', focus: false do
      put repository_content_url(@repository_moomin), params: { repository: { data_content: 'Foo', specimen_content: 'Bar' } }
      expect(response).to have_http_status(:found)
      expect(flash[:success]).to eq('You have successfully updated repository content.')
    end
  end
end
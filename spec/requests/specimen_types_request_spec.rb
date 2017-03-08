require 'rails_helper'
describe SpecimenTypesController, type: :request do
  before(:each) do
    @moomin_repository = FactoryGirl.create(:repository, name: 'Moomins')
    @paul_user = FactoryGirl.create(:northwestern_user, email: 'paulie@whitesox.com', username: 'pkonerko', first_name: 'Paul', last_name: 'Konerko')
  end

  describe 'regular user' do
    before(:each) do
      sign_in @paul_user
    end

    it 'should deny access to index of specimen types', focus: false do
      get repository_specimen_types_url(@moomin_repository)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to update specimen types', focus: false do
      patch bulk_update_repository_specimen_types_url(@moomin_repository), params: { format: :js, repository: { specimen_types_attributes: { "1483750066749"=>{ name: 'Moomin', id: nil , _destroy: false } } } }
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
      get repository_specimen_types_url(@moomin_repository)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to update a repository user', focus: false do
      patch bulk_update_repository_specimen_types_url(@moomin_repository), params: { format: :js, repository: { specimen_types_attributes: { "1483750066749"=>{ name: 'Moomin', id: nil , _destroy: false } } } }
      expect(response).to redirect_to(repository_specimen_types_url(@moomin_repository))
      expect(flash[:success]).to eq('You have successfully updated specimen types.')
    end
  end

  describe 'repository administrator user' do
    before(:each) do
      @moomin_repository.repository_users.build(username: @paul_user.username, administrator: true)
      @moomin_repository.save!

      sign_in @paul_user
    end

    it 'should allow access to index of repository users', focus: false do
      get repository_specimen_types_url(@moomin_repository)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to update a repository user', focus: false do
      patch bulk_update_repository_specimen_types_url(@moomin_repository), params: { format: :js, repository: { specimen_types_attributes: { "1483750066749"=>{ name: 'Moomin', id: nil , _destroy: false } } } }
      expect(response).to redirect_to(repository_specimen_types_url(@moomin_repository))
      expect(flash[:success]).to eq('You have successfully updated specimen types.')
    end
  end
end
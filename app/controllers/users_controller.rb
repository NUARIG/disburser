class UsersController < ApplicationController
  before_action :load_repository, only: :index
  def index
    params[:page]||= 1
    @all_users = User.search_ldap(params[:q], @repository)
    @users = @all_users.paginate(per_page: 10, page: params[:page])
    respond_to do |format|
        format.json {
          render json: {
            users: @users,
            total: @all_users.count,
            links: { self: @users.current_page , next: @users.next_page }
        }.to_json
      }
    end
  end

  private
    def load_repository
      @repository = Repository.find(params[:repository_id])
    end
end
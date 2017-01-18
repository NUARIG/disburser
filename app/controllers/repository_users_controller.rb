class RepositoryUsersController < ApplicationController
  before_action :authenticate_user!
  helper_method :sort_column, :sort_direction
  before_action :load_repository, only: [:index, :new, :create, :edit]
  before_action :load_repository_user, only: [:edit, :update]

  def index
    authorize @repository.repository_users.new
    params[:page]||= 1
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction
    @repository_users = @repository.repository_users.search_across_fields(params[:search], options).paginate(per_page: 10, page: params[:page])
  end

  def new
    @repository_user = @repository.repository_users.new
    authorize @repository_user
    @users = []
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def create
    @repository_user = @repository.repository_users.new(repository_user_params)
    authorize @repository_user
    respond_to do |format|
      if @repository_user.save
        format.js { }
      else
        @users = []
        format.js { render action: 'new', layout: false, status: :unprocessable_entity }
      end
    end
  end

  def edit
    authorize @repository_user
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def update
    authorize @repository_user
    respond_to do |format|
      if @repository_user.update_attributes(repository_user_params)
        format.js { }
      else
        format.js { render json: { errors: @repository_user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private
    def repository_user_params
      params.require(:repository_user).permit(:repository_id, :username, :administrator, :committee, :specimen_coordinator, :data_coordinator)
    end

    def load_repository
      @repository = Repository.find(params[:repository_id])
    end

    def load_repository_user
      @repository_user = RepositoryUser.find(params[:id])
    end

    def sort_column
      ['users.username', 'users.email', 'users.first_name', 'users.last_name', 'repository_users.administrator', 'repository_users.committee', 'repository_users.specimen_coordinator', 'repository_users.data_coordinator'].include?(params[:sort]) ? params[:sort] : 'users.username'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end
end
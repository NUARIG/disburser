class RepositoriesController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :load_repository, only: [:edit, :update]

  def index
    params[:page]||= 1
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction
    @repositories = Repository.search_across_fields(params[:search], options).paginate(per_page: 10, page: params[:page])
  end

  def new
    @repository = Repository.new()
  end

  def create
    @repository = Repository.new(repository_params)

    if @repository.save
      flash[:success] = 'You have successfully created a repository.'
      redirect_to repositories_url
    else
      flash.now[:alert] = 'Failed to create repository.'
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @repository.update(repository_params)
      flash[:success] = 'You have successfully updated a repository.'
      redirect_to repositories_url
    else
      flash.now[:alert] = 'Failed to update repository.'
      render action: 'edit'
    end
  end

  private
    def repository_params
      params.require(:repository).permit(:name, :data, :specimens)
    end

    def load_repository
      @repository = Repository.find(params[:id])
    end

    def sort_column
      ['name', 'data', 'specimens'].include?(params[:sort]) ? params[:sort] : 'name'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end
end
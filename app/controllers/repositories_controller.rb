class RepositoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_repository, only: [:edit, :show, :update]
  helper_method :sort_column, :sort_direction

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
      redirect_to edit_repository_url(@repository)
    else
      flash.now[:alert] = 'Failed to create repository.'
      render action: 'new'
    end
  end

  def show
    redirect_to edit_repository_url(@repository)
  end

  def edit
  end

  def update
    if @repository.update_attributes(repository_params)
      case params[:tab]
      when 'specimen_types'
        flash[:success] = 'You have successfully updated specimen types.'
        redirect_to repository_specimen_types_url(@repository)
      else
        flash[:success] = 'You have successfully updated a repository.'
        redirect_to edit_repository_url(@repository)
      end
    else
      case params[:tab]
      when 'specimen_types'
        flash.now[:alert] = 'Failed to update specimen types.'
        render 'specimen_types/index'
      else
        flash.now[:alert] = 'Failed to update repository.'
        render action: 'edit'
      end
    end
  end

  private
    def repository_params
      params.require(:repository).permit(:name, :data, :specimens, specimen_types_attributes: [:id, :name, :volume, :_destroy])
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
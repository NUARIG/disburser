class RepositoriesController < ApplicationController
  before_action :authenticate_user!, except: [:show, :download_file]
  before_action :load_repository, only: [:edit, :show, :update, :download_file]
  helper_method :sort_column, :sort_direction

  def index
    authorize Repository
    params[:page]||= 1
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction

    if current_user.system_administrator
      r = Repository
    else
      r = current_user.repositories
    end
    @repositories = r.search_across_fields(params[:search], options).paginate(per_page: 10, page: params[:page])
  end

  def new
    authorize Repository
    @repository = Repository.new()
  end

  def create
    authorize Repository
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
    authorize @repository
  end

  def edit
    authorize @repository
  end

  def update
    authorize @repository
    if @repository.update_attributes(repository_params)
      flash[:success] = 'You have successfully updated a repository.'
      redirect_to edit_repository_url(@repository)
    else
      flash.now[:alert] = 'Failed to update repository.'
      render action: 'edit'
    end
  end

  def download_file
    case params[:file_type]
    when 'custom_request_form'
      file = @repository.custom_request_form.path
    when 'data_dictionary'
      file = @repository.data_dictionary.path
    when 'irb_template'
      file = @repository.irb_template.path
    end

    return send_file file, disposition: 'attachment', x_sendfile: true unless file.blank?
  end

  private
    def repository_params
      params.require(:repository).permit(:name, :public, :custom_request_form, :custom_request_form_cache, :remove_custom_request_form, :irb_template, :irb_template_cache, :remove_irb_template, :data_dictionary, :data_dictionary_cache, :remove_data_dictionary, :committee_email_reminder, :notify_repository_administrator,  specimen_types_attributes: [:id, :name, :_destroy])
    end

    def load_repository
      @repository = Repository.find(params[:id])
    end

    def sort_column
      ['name'].include?(params[:sort]) ? params[:sort] : 'name'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end
end
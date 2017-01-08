class DisburserRequestsController < ApplicationController
  before_action :authenticate_user!
  helper_method :sort_column, :sort_direction
  before_action :load_repository, only: [:new, :create, :edit, :update]
  before_action :load_disburser_request, only: [:edit, :update, :download_file]

  def index
    # authorize DisburserRequest
    params[:page]||= 1
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction

    if current_user.system_administrator
      dr = DisburserRequest
    else
      dr = current_user.disburser_requests
    end
    @disburser_requests = dr.search_across_fields(params[:search], options).paginate(per_page: 10, page: params[:page])
  end

  def new
    @disburser_request = @repository.disburser_requests.new(submitter: current_user)
    # authorize @disburser_request
  end

  def create
    @disburser_request = @repository.disburser_requests.new(disburser_request_params)
    @disburser_request.submitter = current_user
    # authorize @repository_user
    if @disburser_request.save
      flash[:success] = 'You have successfully created a repository request.'
      redirect_to disburser_requests_url
    else
      flash.now[:alert] = 'Failed to create repository request.'
      render action: 'new'
    end
  end

  def edit
    # authorize @disburser_request
  end

  def update
    if params[:disburser_request][:methods_justifications_cache].blank? && params[:disburser_request][:methods_justifications].blank?
      @disburser_request.methods_justifications = nil
    end

    if @disburser_request.update_attributes(disburser_request_params)
      flash[:success] = 'You have successfully updated a repository request.'
      redirect_to disburser_requests_url
    else
      flash.now[:alert] = 'Failed to update repository request.'
      render action: 'edit'
    end
  end

  def download_file
    case params[:file_type]
    when 'methods_justifications'
      file = @disburser_request.methods_justifications.path
    end

    return send_file file, disposition: 'attachment', x_sendfile: true unless file.blank?
  end

  private
    def disburser_request_params
      params.require(:disburser_request).permit(:repository_id, :title, :investigator, :irb_number, :specimens, :feasibility, :cohort_criteria, :data_for_cohort, :methods_justifications, :methods_justifications_cache, :remove_methods_justifications, disburser_request_details_attributes: [:id, :quantity, :volume, :comments, :_destroy])
    end

    def load_repository
      @repository = Repository.find(params[:repository_id])
    end

    def load_disburser_request
      @disburser_request = DisburserRequest.find(params[:id])
    end

    def sort_column
      ['title', 'specimens'].include?(params[:sort]) ? params[:sort] : 'title'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end
end
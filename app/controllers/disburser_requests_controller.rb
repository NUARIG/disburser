class DisburserRequestsController < ApplicationController
  before_action :authenticate_user!
  helper_method :sort_column, :sort_direction
  before_action :load_repository, only: [:new, :create, :edit, :update]
  before_action :load_disburser_request, only: [:edit, :update, :edit_admin_status, :edit_data_status, :edit_specimen_status, :download_file, :data_status, :specimen_status, :admin_status, :edit_committee_review, :committee_review]
  before_action :load_specimen_types, only: [:new, :create, :edit, :update]

  def index
    params[:page]||= 1
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction

    @disburser_requests = current_user.disburser_requests.search_across_fields(params[:search], options).paginate(per_page: 10, page: params[:page])
  end

  def admin
    authorize DisburserRequest
    params[:page]||= 1
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction

    @disburser_requests = current_user.admin_disbursr_requests.search_across_fields(params[:search], options).paginate(per_page: 10, page: params[:page])
  end

  def committee
    authorize DisburserRequest
    params[:page]||= 1
    params[:status]||= DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
    params[:vote_status]||= DisburserRequest::DISBURSER_REQUEST_VOTE_STATUS_PENDING_MY_VOTE
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction

    @disburser_requests = current_user.committee_disburser_requests(status: params[:status]).by_vote_status(current_user, params[:vote_status]).search_across_fields(params[:search], options).paginate(per_page: 10, page: params[:page])
  end

  def data_coordinator
    authorize DisburserRequest
    params[:page]||= 1
    params[:fulfillment_status]||= DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_NOT_STARTED
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction

    @disburser_requests = current_user.data_coordinator_disbursr_requests(status: params[:status], fulfillment_status: params[:fulfillment_status]).search_across_fields(params[:search], options).paginate(per_page: 10, page: params[:page])
  end

  def specimen_coordinator
    authorize DisburserRequest
    params[:page]||= 1
    params[:fulfillment_status]||= DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction

    @disburser_requests = current_user.specimen_coordinator_disbursr_requests(status: params[:status], fulfillment_status: params[:fulfillment_status]).search_across_fields(params[:search], options).paginate(per_page: 10, page: params[:page])
  end

  def new
    @disburser_request = @repository.disburser_requests.new(submitter: current_user)
  end

  def edit
    authorize @disburser_request
  end

  def create
    if !params[:disburser_request][:methods_justifications_cache].blank? && params[:disburser_request][:methods_justifications].blank?
      params[:disburser_request][:methods_justifications] = params[:disburser_request][:methods_justifications_cache]
    end

    @disburser_request = DisburserRequest.new(disburser_request_params)

    if params[:disburser_request][:methods_justifications_cache].blank? && params[:disburser_request][:methods_justifications].blank?
      @disburser_request.methods_justifications = nil
    end
    @disburser_request.repository = @repository
    @disburser_request.submitter = current_user
    @disburser_request.status_user = current_user

    if @disburser_request.save
      flash[:success] = 'You have successfully created a repository request.'
      redirect_to disburser_requests_url
    else
      flash.now[:alert] = 'Failed to create repository request.'
      render action: 'new'
    end
  end

  def update
    authorize @disburser_request

    if params[:disburser_request][:methods_justifications_cache].blank? && params[:disburser_request][:methods_justifications].blank?
      @disburser_request.methods_justifications = nil
    end
    @disburser_request.assign_attributes(disburser_request_params)
    @disburser_request.status_user = current_user
    if @disburser_request.save
      flash[:success] = 'You have successfully updated a repository request.'
      redirect_to disburser_requests_url
    else
      flash.now[:alert] = 'Failed to update repository request.'
      render action: 'edit'
    end
  end

  def download_file
    authorize @disburser_request
    case params[:file_type]
    when 'methods_justifications'
      file = @disburser_request.methods_justifications.path
    end

    return send_file file, disposition: 'attachment', x_sendfile: true unless file.blank?
  end

  def edit_admin_status
    authorize @disburser_request
    load_specimen_types_from_disburser_request
  end

  def edit_committee_review
    authorize @disburser_request
    @disburser_request_vote = @disburser_request.find_or_initialize_disburser_request_vote(current_user)
  end

  def edit_data_status
    authorize @disburser_request
  end

  def edit_specimen_status
    authorize @disburser_request
  end

  def data_status
    authorize @disburser_request
    @disburser_request.assign_attributes(disburser_request_params)
    @disburser_request.status_user = current_user
    if @disburser_request.save
      flash[:success] = 'You have successfully updated the status of a repository request.'
      redirect_to data_coordinator_disburser_requests_url
    else
      flash.now[:alert] = 'Failed to update the status of a repository request.'
      render action: 'edit_data_status'
    end
  end

  def specimen_status
    authorize @disburser_request
    @disburser_request.assign_attributes(disburser_request_params)
    @disburser_request.status_user = current_user
    if @disburser_request.save
      flash[:success] = 'You have successfully updated the status of a repository request.'
      redirect_to specimen_coordinator_disburser_requests_url
    else
      flash.now[:alert] = 'Failed to update the status of a repository request.'
      render action: 'edit_specimen_status'
    end
  end

  def admin_status
    authorize @disburser_request
    load_specimen_types_from_disburser_request
    @disburser_request.assign_attributes(disburser_request_params)
    @disburser_request.status_user = current_user
    if @disburser_request.save
      flash[:success] = 'You have successfully updated the status of a repository request.'
      redirect_to admin_disburser_requests_url
    else
      flash.now[:alert] = 'Failed to update the status of a repository request.'
      render action: 'edit_admin_status'
    end
  end

  private
    def load_specimen_types_from_disburser_request
      @specimen_types = @disburser_request.repository.specimen_types.order('name ASC').map { |specimen_type| [specimen_type.name, specimen_type.id] }
    end

    def load_specimen_types
      @specimen_types = @repository.specimen_types.order('name ASC').map { |specimen_type| [specimen_type.name, specimen_type.id] }
    end

    def disburser_request_params
      params.require(:disburser_request).permit(:status_comments, :status, :fulfillment_status, :title, :investigator, :irb_number, :feasibility, :cohort_criteria, :data_for_cohort, :methods_justifications, :methods_justifications_cache, :remove_methods_justifications, disburser_request_details_attributes: [:disburser_request_id, :id, :specimen_type_id, :quantity, :volume, :comments, :_destroy])
    end

    def load_repository
      @repository = Repository.find(params[:repository_id])
    end

    def load_disburser_request
      @disburser_request = DisburserRequest.find(params[:id])
    end

    def sort_column
      ['title', 'investigator', 'irb_number', 'feasibility', 'status', 'fulfillment_status', 'users.last_name', 'repositories.name'].include?(params[:sort]) ? params[:sort] : 'title'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end
end
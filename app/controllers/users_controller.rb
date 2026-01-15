class UsersController < ApplicationController
  before_action :authenticate_user!, except: :login
  before_action :load_repository, only: :index
  before_action :load_user, only: :show
  prepend_before_action :check_captcha, only: [:create]
  
  def index
    params[:page]||= 1
    @all_users = User.search(params[:q], @repository)
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

  def show
  end

  def sigin_in
  end

  private
    def load_repository
      @repository = Repository.find(params[:repository_id])
    end

    def load_user
      @user = User.find(params[:id])
    end

    def check_captcha
      unless verify_recaptcha
        self.resource = resource_class.new(sign_in_params)
        respond_with_navigational(resource) do
          flash.now[:alert] = "reCAPTCHA verification failed"
          render :new
        end
      end
    end    
end
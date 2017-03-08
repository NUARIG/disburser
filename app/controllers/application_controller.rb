class ApplicationController < ActionController::Base
  UNAUTHORIZED_MESSAGE = "You are not authorized to perform this action."
  protect_from_forgery with: :exception
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_paper_trail_whodunnit

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end

  def authenticate_user!
    if (!northwestern_user_signed_in? && !external_user_signed_in?)
      flash[:alert] = 'You need to sign in or sign up before continuing.'
      redirect_to login_url
    end
  end

  def current_user
    current_northwestern_user || current_external_user
  end

  def after_update_path_for(resource)
    user_path(resource)
  end

  helper_method :current_user
  helper_method :destroy_user_session_path

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_in) do |user_params|
        user_params.permit(:username, :email, :password)
      end

      devise_parameter_sanitizer.permit(:sign_up) do |user_params|
        user_params.permit(:username, :email, :password, :last_name, :first_name)
      end

      devise_parameter_sanitizer.permit(:account_update) do |user_params|
        user_params.permit(:current_password, :password, :password_confirmation, :last_name, :first_name)
      end
    end

  private
    def after_sign_out_path_for(resource_or_scope)
      root_path
    end

    def user_not_authorized
      flash[:alert] = UNAUTHORIZED_MESSAGE
      redirect_to(request.referrer || root_path)
    end
end
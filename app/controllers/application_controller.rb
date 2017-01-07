class ApplicationController < ActionController::Base
  UNAUTHORIZED_MESSAGE = "You are not authorized to perform this action."
  protect_from_forgery with: :exception
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_in) do |user_params|
        user_params.permit(:username, :password)
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
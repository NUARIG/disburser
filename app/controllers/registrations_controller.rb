class  RegistrationsController < Devise::RegistrationsController
  prepend_before_action :check_captcha, only: [:create]
  protected
    def after_update_path_for(resource)
      user_path(resource)
    end
    
  private

    def check_captcha
      unless verify_recaptcha
        self.resource = resource_class.new sign_up_params
        resource.validate # Look for any other validation errors besides reCAPTCHA
        set_minimum_password_length
        respond_with_navigational(resource) { render :new }
      end
    end  
end
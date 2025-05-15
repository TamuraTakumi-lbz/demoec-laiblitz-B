class AdminUsersController < Devise::RegistrationsController
  before_action :basic_authenticate, only:[:new]
  before_action :set_admin_flag, only: [:new, :create]




  private
  def set_admin_flag
    @admin_signup = true
  end

  def sign_up_params
    super.tap do |whitelisted|
      whitelisted[:is_admin] = @admin_signup
    end
  end

  def after_sign_up_path_for(resource)
    root_path
  end

  def basic_authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV["BASIC_AUTH_USER"] && password == ENV["BASIC_AUTH_PASSWORD"]
    end
  end
end

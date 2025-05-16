class AdminUsersController < Devise::RegistrationsController
  before_action :redirect_logout_user, only: [:index]
  before_action :authenticate_admin, only: [:index]
  before_action :set_admin_flag, only: [:new, :create]

  def index
    
    @admin_users = User.all
  end

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

  def authenticate_admin
    unless current_user.is_admin?
      redirect_to root_path
    end
  end

  def redirect_logout_user
    if current_user == nil
      redirect_to new_user_session_path
      return
    end
  end
end

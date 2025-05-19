class AdminUsersController < Devise::RegistrationsController

  before_action :basic_authenticate, only:[:new]
  before_action :redirect_logout_user, only: [:index]
  before_action :authenticate_admin, only: [:index]
  before_action :set_admin_flag, only: [:new, :create]

  def index
    @admin_users = User.all
  end

  def destroy
    user = User.find(params[:id])
    purchases = Purchase.where(user_id: user.id)
    item_ids = purchases.map(&:item_id)
    # begin
    #   ActiveRecord::Base.transaction do
    if user.destroy
      items = Item.where(id: item_ids).destroy_all
      redirect_to admin_users_path
    #   end
    # rescue 
    else
      render :index, status: :unprocessable_entity
    end
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

  def basic_authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV["BASIC_AUTH_USER"] && password == ENV["BASIC_AUTH_PASSWORD"]

    end
  end
end

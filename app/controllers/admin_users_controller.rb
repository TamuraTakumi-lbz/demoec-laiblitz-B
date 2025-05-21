class AdminUsersController < Devise::RegistrationsController
  before_action :basic_authenticate, only: [:new]
  before_action :redirect_logout_user, only: [:index]
  before_action :authenticate_admin, only: [:index]
  before_action :set_admin_flag, only: [:new, :create]

  def index
    @users = User.all
  end

  def destroy
    user = User.find(params[:id])
    purchases = Purchase.where(user_id: user.id)
    purchase_item = PurchaseItem.where(purchase_id: purchases.ids)

    items = Item.where(id: purchase_item.map(&:item_id))

    ActiveRecord::Base.transaction do
      purchases.destroy_all
      purchase_item.destroy_all
      items.destroy_all

      user.destroy
      redirect_to admin_users_path
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "モデル保存エラーが発生しました: #{e.message}"
    flash.now[:alert] = "データの保存に失敗しました: #{e.message}"
    render :index, status: :unprocessable_entity
  rescue StandardError => e
    Rails.logger.error "予期せぬエラーが発生しました: #{e.message}"
    flash.now[:alert] = '予期せぬエラーが発生しました。時間をおいてお試しください。'
    render :index, status: :unprocessable_entity
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
    return if current_user.is_admin?

    redirect_to root_path
  end

  def redirect_logout_user
    return unless current_user.nil?

    redirect_to new_user_session_path
    nil
  end

  def basic_authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV['BASIC_AUTH_USER'] && password == ENV['BASIC_AUTH_PASSWORD']
    end
  end
end

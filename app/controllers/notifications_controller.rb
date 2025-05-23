class NotificationsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :authenticate_admin, only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :set_notification, only: [:edit, :update, :destroy]
  
  def index
    @notifications = Notification.order(created_at: :DESC)
  end
  def new
    @notification = Notification.new
  end
  def create
    @notification = Notification.new(notification_params)
    @notification[:is_published] = false
    if @notification.save
      redirect_to notifications_path
    else
      render :new, status: :unprocessable_entity
    end

  end

  def edit

  end
  def update
    if @notification.update(notification_params)
      redirect_to notifications_path
    else
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    if @notification.destroy
      redirect_to notifications_path
    else
      render :index, status: :unprocessable_entity
    end
  end

  def dashboard

  end

  private
  def set_notification
    @notification = Notification.find(params[:id])
  end
  def notification_params
    params.require(:notification).permit(:title,:content,:starts_at, :ends_at)
  end
  def published_flag_params
    params.require(:notification).permit(:is_published)
  end
  def authenticate_admin
    return if current_user.is_admin?

    redirect_to root_path
  end
end

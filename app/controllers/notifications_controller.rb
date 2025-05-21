class NotificationsController < ApplicationController

  before_action :set_notification, only: [:edit, :update, :destroy]
  
  def index
    @notifications = Notification.all
  end
  def new
    @notification = Notification.new
  end
  def create
    @notification = Notification.new(notification_params)
    if @notification.save
      redirect_to notifications_path
    else
      render :index, status: :unprocessable_entity
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

  private
  def set_notification
    @notification = Notification.find(params[:id])
  end
  def notification_params
    params.require(:notification).permit(:title,:content,:starts_at, :ends_at)
  end
end

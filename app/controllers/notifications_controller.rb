class NotificationsController < ApplicationController
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


  private
  def notification_params
    params.require(:notification).permit(:title,:content,:starts_at, :ends_at)
  end
end

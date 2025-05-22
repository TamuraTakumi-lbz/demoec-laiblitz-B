class NotificationsController < ApplicationController

  before_action :set_notification, only: [:edit, :update, :destroy]
  
  def index
    @notifications = Notification.where(is_published: true) 

    Notification.where(is_published: false).find_each do |notification|
      logger.debug(notification[:id])
      logger.debug(notification[:starts_at])
      logger.debug(Time.current)

      if notification[:starts_at] <= Time.current
        notification[:is_published] = true
        notification.save
      end
      if !(notification[:ends_at]==nil) && (notification[:ends_at] < Time.now)
        notification[:is_published] = false
        notification.save
      end
    end
  end
  def new
    @notification = Notification.new
  end
  def create
    notification = Notification.new(notification_params)
    notification[:is_published] = false
    if notification.save
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
end

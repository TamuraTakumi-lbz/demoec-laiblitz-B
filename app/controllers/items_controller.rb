class ItemsController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard]
  before_action :authenticate_admin, only: [:dashboard]

  def dashboard
    @items = Item.order(created_at: :desc)
  end

  def index
    @items = Item.order('created_at DESC')
  end

  def destroy
    item = Item.find(params[:id])
    if item.destroy
      redirect_to items_dashboard_path
    else
      render :dashboard
    end
  end

  private

  def authenticate_admin
    return if current_user.is_admin?

    redirect_to root_path
  end
end

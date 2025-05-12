class ItemsController < ApplicationController
  before_action :authenticate_admin, only: [:dashboard]
  before_action :authenticate_login_user, only: [:dashboard]

  def dashboard
    @items=Item.includes([:condition,:category]).order(created_at: :desc)
  end

  private
  def authenticate_admin
    unless current_user.is_admin
      redirect_to root_path
    end
  end

  def authenticate_login_user
     unless user_signed_in?
      redirect_to root_path
    end
  end
end

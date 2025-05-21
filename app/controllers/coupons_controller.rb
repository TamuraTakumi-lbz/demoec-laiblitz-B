class CouponsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :authenticate_admin, except: [:show]
  before_action :set_coupon, only: [:show, :edit, :update, :destroy]

  def index
    @coupons = Coupon.all.order(created_at: :DESC)
  end

  def show
  end

  def new
    @coupon=Coupon.new
  end

  def create
    @coupon = Coupon.new(coupon_params)
    if @coupon.save
      redirect_to coupons_path
    else
      render :new, status: :unprocessable_entity
  end

  def edit

  end

  def update
    if @coupon.update(coupon_params)
      redirect_to coupons_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @coupon.destroy
      redirect_to coupons_path
    else
      render :index, status: :unprocessable_entity
    end
  end

  private
  def authenticate_admin
    return if current_user.is_admin?
    redirect_to root_path
  end

  def coupon_params
    params.require(:coupon).permit(
      :name, :description, 
      :discount_amount, 
      :minimum_order_price,
      :expires_on,
      :is_active
    )

  def set_coupon
    @coupon = Coupon.find(params[:id])
  end
end

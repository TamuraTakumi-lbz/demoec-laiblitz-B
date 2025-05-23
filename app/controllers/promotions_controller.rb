class PromotionsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :authenticate_admin, only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :set_promotion, only: [:edit, :update, :destroy]

  def index
    @promotions = Promotion.order(created_at: :DESC)
  end

  def new
    @promotion = Promotion.new
  end

  def create
    @promotion = Promotion.new(promotion_params)
    if @promotion.save
      redirect_to promotions_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit

  end

  def update
    if @promotion.update(promotion_params)
      redirect_to promotions_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @promotion.destroy
      redirect_to promotions_path
    else
      render :index, status: :unprocessable_entity
    end
  end

  private
  
  def promotion_params
    params.require(:promotion).permit(:promotion_image, :title,:content,:starts_at, :ends_at, :url)
  end

  def set_promotion
    @promotion = Promotion.find(params[:id])
  end

  def authenticate_admin
    return if current_user.is_admin?

    redirect_to root_path
  end
end

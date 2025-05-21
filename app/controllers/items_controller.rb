class ItemsController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard, :new, :create, :edit, :update, :destroy]
  before_action :authenticate_admin, only: [:dashboard, :new, :create, :edit, :update, :destroy]
  before_action :set_item, only: [:edit, :show, :update, :destroy]

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to items_dashboard_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @category = Category.find(@item.category_id)
    @condition = Condition.find(@item.condition_id)
  end

  def dashboard
    @items = Item.order(created_at: :DESC)
  end

  def index
    @items = Item.order(created_at: :DESC)
  end

  def search
    @q = Item.ransack(params[:q])
    @items = @q.result(distinct: true).order(created_at: :DESC)
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to items_dashboard_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    if @item.destroy
      redirect_to items_dashboard_path
    else
      render :dashboard, status: :unprocessable_entity
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :image, :description, :price, :category_id, :condition_id)
  end

  def authenticate_admin
    return if current_user.is_admin?

    redirect_to root_path
  end

  def set_item
    @item = Item.find(params[:id])
  end
end

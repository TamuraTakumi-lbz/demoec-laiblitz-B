class ItemsController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard, :new, :edit]
  before_action :authenticate_admin, only: [:dashboard, :new]

  def edit
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])
    if @item.update(item_params)
      redirect_to items_dashboard_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @item = Item.find(params[:id])
    @category = Category.find(@item.category_id)
    @condition = Condition.find(@item.condition_id)
  end

  def dashboard
    @items=Item.order(created_at: :desc)
  end

  def index
    @items = Item.order("created_at DESC")
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  def item_params
    params.require(:item).permit(:name,:image,:description,:price,:category_id,:condition_id)
  end
  def authenticate_admin
    unless current_user.is_admin?
      redirect_to root_path
    end
  end

end

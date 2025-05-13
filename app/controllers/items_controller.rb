class ItemsController < ApplicationController
  def show
    @item = Item.find(params[:id])
    @category = Category.find(@item.category_id)
    @condition = Condition.find(@item.condition_id)
  end

  def index
    @items = Item.includes(:category).order("created_at DESC")
  end
  
end

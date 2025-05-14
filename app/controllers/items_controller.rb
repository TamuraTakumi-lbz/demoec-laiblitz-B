class ItemsController < ApplicationController
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
    
  def index
    @items = Item.order("created_at DESC")
  end

  private
  def item_params
    params.require(:item).permit(:name,:image,:description,:price,:category_id,:condition_id)
  end
end

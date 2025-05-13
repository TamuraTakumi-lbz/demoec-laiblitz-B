class ItemsController < ApplicationController
  def dashboard
    @items=Item.order(created_at: :desc)
  end
  
  def index
    @items = Item.order("created_at DESC")
  end
end

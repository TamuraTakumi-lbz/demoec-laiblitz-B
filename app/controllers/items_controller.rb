class ItemsController < ApplicationController
  def new
    
  end
    
  def index
    @items = Item.order("created_at DESC")
  end
end

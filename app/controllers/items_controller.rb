class ItemsController < ApplicationController
  def new
    
  end
    
  def index
    @items = Item.includes(:category).order("created_at DESC")
  end
end

class ItemsController < ApplicationController
  def new
    
  def index
    @items = Item.includes(:category).order("created_at DESC")
  end
end

class ItemsController < ApplicationController
  def index
    @items = Item.includes(:category).order("created_at DESC")
  end
end

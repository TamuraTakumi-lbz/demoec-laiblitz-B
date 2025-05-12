class ItemsController < ApplicationController
  def index
    @items = Item.includes(:category)
  end
end

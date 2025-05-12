class ItemsController < ApplicationController
  def dashboard
    @items=Item.includes([:condition,:category]).order(created_at: :desc)
  end
end

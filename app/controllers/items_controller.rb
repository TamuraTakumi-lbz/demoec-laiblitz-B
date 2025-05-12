class ItemsController < ApplicationController
  def index
  end

  def edit
    @item = Item.find(1)
  end

  def update
    # ダッシュボードに戻す。適宜パスは修正
    @item = Item.find(params[:id])
    if @item.update(item_params)
      redirect_to dashboard_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :email, :description, :price)
  end
end

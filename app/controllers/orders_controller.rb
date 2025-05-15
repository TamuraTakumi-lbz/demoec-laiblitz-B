class OrdersController < ApplicationController
  def new
    @item = Item.find(params[:id])
    @order = Ship.new
  end

  def create
    binding.pry
    @order = Ship.new(ship_params.merge(purchase_id: nil))
    # payjp_token = params[:token]

    if @order.valid?
      ActiveRecord::Base.transaction do
        @purchase = Purchase.create!(user_id: current_user.id, item_id: @item.id)
        @order.purchase_id = @purchase.id
        @order.save!
        redirect_to root_path, notice: '購入が完了しました！'
      end
    else
      render :new, status: :unprocessable_entity
    end
  rescue PayjpService::Error, ActiveRecord::RecordInvalid => e
    Rails.logger.error "購入処理中にエラーが発生しました: #{e.message}"
    flash.now[:alert] = '購入処理中にエラーが発生しました。もう一度お試しください。'
    render :new, status: :unprocessable_entity
  end

  def order_params
    params.require(:ship).permit(:price).merge(token: params[:token])
  end
end

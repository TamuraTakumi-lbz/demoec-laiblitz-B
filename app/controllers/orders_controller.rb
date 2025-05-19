class OrdersController < ApplicationController
  # before_action :set_item, only: [:new, :create]
  def new
    @item = Item.find(params[:id])
    redirect_to root_path if current_user.is_admin?

    gon.public_key = ENV["PAYJP_PUBLIC_KEY"]
    @order = Ship.new
  end

  def create
    @order = Ship.new(ship_params)

    # renderでやり直した時のために設定
    gon.public_key = ENV["PAYJP_PUBLIC_KEY"]

    payjp_token = params[:token]

    if @order.valid?
      Payjp.api_key = ENV["PAYJP_SECRET_KEY"]

      charge = Payjp::Charge.create(
        amount: @item.price,
        card: payjp_token,
        currency: 'jpy'
      )

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

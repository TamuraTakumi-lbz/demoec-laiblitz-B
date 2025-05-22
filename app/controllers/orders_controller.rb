class OrdersController < ApplicationController
  before_action :set_item, only: %i[new create]

  def new
    # 購入可能な状態以外はページ遷移
    return redirect_to new_user_session_path unless user_signed_in?
    return redirect_to root_path if current_user&.is_admin? || PurchaseItem.exists?(item_id: @item.id)

    gon.public_key = ENV['PAYJP_PUBLIC_KEY']
    @order = Ship.new
    #有効かつ、userが未使用のクーポン取得。Userモデル内で定義。
    @available_coupons = current_user.available_coupons
  end

  def create
    gon.public_key = ENV['PAYJP_PUBLIC_KEY']
    payjp_token = params[:token]

    creator = PurchaseCreator.new(
      user: current_user,
      item: @item,
      ship_params: ship_params,
      payjp_token: payjp_token,
      # クーポンidを受け取り
      coupon_id:   coupon_id
    )

    if creator.call
      redirect_to root_path, notice: '購入が完了しました！'
    else
      @order = Ship.new(ship_params)
      #利用可能クーポンの再セット
      @available_coupons = current_user.available_coupons

      # Service Object から取得したエラーメッセージを @order の errors に追加
      creator.errors.each do |message|
        @order.errors.add(:base, message)
      end
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_item
    @item = Item.find(params[:id] || params[:item_id])
  end

  def ship_params
    params.require(:ship).permit(
      :postal_code,
      :prefecture_id,
      :city,
      :street_address,
      :building_name,
      :phone_number
    )
  end
end

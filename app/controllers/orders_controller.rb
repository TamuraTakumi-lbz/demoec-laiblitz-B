class OrdersController < ApplicationController
  before_action :set_item, only: %i[new create]

  def new
    # 購入可能な状態以外はページ遷移
    return redirect_to new_user_session_path unless user_signed_in?
    return redirect_to root_path if current_user&.is_admin? || Purchase.exists?(item_id: @item.id)

    gon.public_key = ENV['PAYJP_PUBLIC_KEY']
    @order = Ship.new
  end

  def create
    @order = Ship.new(ship_params)

    # renderでやり直した時のために設定
    gon.public_key = ENV['PAYJP_PUBLIC_KEY']

    payjp_token = params[:token]

    if @order.valid?
      Payjp.api_key = ENV['PAYJP_SECRET_KEY']

      charge = Payjp::Charge.create(
        amount: @item.price,
        card: payjp_token,
        currency: 'jpy'
      )

      ActiveRecord::Base.transaction do
        @purchase = Purchase.create!(user_id: current_user.id, item_id: @item.id)

        @order.purchases_id = @purchase.id
        @order.save!

        redirect_to root_path, notice: '購入が完了しました！'
      end
    else
      render :new, status: :unprocessable_entity
    end
  rescue Payjp::PayjpError => e
    Rails.logger.error "Payjp決済エラーが発生しました: #{e.message}"
    flash.now[:alert] = "決済処理に失敗しました: #{e.message}"
    render :new, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "モデル保存エラーが発生しました: #{e.message}"
    flash.now[:alert] = "データの保存に失敗しました: #{e.message}"
    render :new, status: :unprocessable_entity
  rescue StandardError => e
    Rails.logger.error "予期せぬエラーが発生しました: #{e.message}"
    flash.now[:alert] = '予期せぬエラーが発生しました。時間をおいてお試しください。'
    render :new, status: :unprocessable_entity
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

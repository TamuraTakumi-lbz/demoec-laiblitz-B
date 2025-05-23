class OrdersController < ApplicationController
  before_action :set_item, only: %i[new create]

  def new
    # 購入可能な状態以外はページ遷移
    return redirect_to new_user_session_path unless user_signed_in?
    return redirect_to root_path if current_user&.is_admin? || PurchaseItem.exists?(item_id: @item.id)

    gon.public_key = ENV['PAYJP_PUBLIC_KEY']
    gon.user_total_points = current_user.total_available_points
    gon.item_price = @item.price
    @order = Ship.new
    # 有効かつ、userが未使用のクーポン取得。Userモデル内で定義。
    @available_coupons = current_user.available_coupons
  end

  def create
    gon.public_key = ENV['PAYJP_PUBLIC_KEY']
    payjp_token = params[:token]

    redemption_amount = params[:points_to_redeem_on_submit].to_i
    coupon_id = params[:selected_coupon_id_on_submit].presence
    @order = Ship.new(ship_params)

    begin ActiveRecord::Base.transaction do
      # ポイント消費
      if redemption_amount > 0
        point_redemption_service = PointRedemptionService.new(user: current_user,
                                                              purchase: nil,
                                                              redemption_amount: redemption_amount).call
        puts point_redemption_service

        unless point_redemption_service.success?
          point_redemption_service.error_message.each do |error_message|
            @order.errors.add(:base, error_message)
          end
          render :new, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
        redemption_amount = point_redemption_service.data[:redemption_points]
      end

      # 購入処理
      creator_result = PurchaseCreator.new(
        user: current_user,
        item: @item,
        ship_params: ship_params,
        payjp_token: payjp_token,
        used_points: redemption_amount,
        point_deal: point_redemption_service.present? ? point_redemption_service.data[:point_deal] : nil,
        coupon_id: coupon_id
      ).call
      puts creator_result

      unless creator_result.success?
        creator_result.error_message.each do |error_message|
          @order.errors.add(:base, error_message)
        end
        render :new, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

      # ポイント付与
      point_awarding_service = PointAwardingService.new(user: current_user,
                                                        purchase: creator_result.data[:purchase],
                                                        type_key: '0001').call
      unless point_awarding_service.success?
        point_award_result.error_message.each do |error_message|
          @order.errors.add(:base, error_message)
        end
        raise ActiveRecord::Rollback
      end
      redirect_to root_path, notice: '購入が完了しました。'
    end
    rescue ActiveRecord::Rollback
      flash.now[:alert] = '購入処理中にエラーが発生しました。'
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

  # def populate_order_errors_from_creator(creator)
  #   if creator.errors.respond_to?(:full_messages) && creator.errors.full_messages.any?
  #     creator.errors.full_messages.each do |message|
  #       @order.errors.add(:base, message)
  #     end
  #   elsif creator.errors.is_a?(Array) && creator.errors.any?
  #     creator.errors.each do |message|
  #       @order.errors.add(:base, message)
  #     end
  #   else
  #     @order.errors.add(:base, '購入処理中にエラーが発生しました。')
  #   end
  # end
end

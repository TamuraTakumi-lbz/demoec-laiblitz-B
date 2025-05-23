class OrdersController < ApplicationController
  before_action :set_item, only: %i[new create]

  def new
    # 購入可能な状態以外はページ遷移
    return redirect_to new_user_session_path unless user_signed_in?
    return redirect_to root_path if current_user&.is_admin? || PurchaseItem.exists?(item_id: @item.id)

    gon.public_key = ENV['PAYJP_PUBLIC_KEY']
    @order = Ship.new
  end

  def create
    gon.public_key = ENV['PAYJP_PUBLIC_KEY']
    payjp_token = params[:token]

    @order = Ship.new(ship_params)

    begin ActiveRecord::Base.transaction do
      creator_result = PurchaseCreator.new(
        user: current_user,
        item: @item,
        ship_params: ship_params,
        payjp_token: payjp_token,
        used_points: 10
      ).call
      binding.pry
      puts creator_result.success?
      unless creator_result.success?
        creator_result.error_message.each do |error_message|
          @order.errors.add(:base, error_message)
        end
        render :new, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

      binding.pry
      point_awarding_service = PointAwardingService.new(user: current_user,
                                                        purchase: creator_result.data[:purchase],
                                                        type_key: '0001')

      point_award_result = point_awarding_service.call

      unless point_award_result.success?
        point_award_result.error_message.each do |error_message|
          @order.errors.add(:base, error_message)
        end
        raise ActiveRecord::Rollback
      end
      redirect_to root_path, notice: '購入が完了しました。'
    end
    rescue ActiveRecord::Rollback
      binding.pry
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

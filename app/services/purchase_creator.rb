class PurchaseCreator
  Result = Struct.new(:success?, :data, :error_message, keyword_init: true)
  attr_reader :purchase

  def initialize(user:, item:, ship_params:, payjp_token:, used_points: 0)
    @user = user
    @item = item
    @ship_params = ship_params
    @payjp_token = payjp_token
    @used_points = used_points.to_i
    @errors = []
  end

  def call
    final_payment_amount = @item.price - @used_points

    return Result.new(success?: false, error_message: '購入金額が0以下です。') if final_payment_amount <= 0
    return Result.new(success?: false, error_message: 'ポイントの使用が0以下です。') if @used_points < 0

    ActiveRecord::Base.transaction do
      binding.pry
      @purchase = Purchase.new(
        user: @user,
        total_price: @item.price,
        used_points: @used_points,
        coupon_discount_amount: 0,
        final_payment_amount: final_payment_amount,
        status: 'pending_payment'
      )
      unless @purchase.save
        return Result.new(success?: false, error_message: @purchase.errors.full_messages.join(', '),
                          data: { errors_object: @purchase.errors })
      end

      @purchase_item = PurchaseItem.new(
        item: @item,
        purchase: @purchase,
        quantity: 1,
        price_at_purchase: @item.price
      )
      unless @purchase_item.save
        return Result.new(success?: false, error_message: @purchase.errors.full_messages.join(', '),
                          data: { errors_object: @purchase_item.errors })
      end

      @ship = Ship.new(@ship_params)
      @ship.purchase = @purchase
      unless @ship.save
        return Result.new(success?: false, error_message: @purchase.errors.full_messages.join(', '),
                          data: { errors_object: @ship.errors })
      end

      if final_payment_amount > 0
        Payjp.api_key = ENV['PAYJP_SECRET_KEY'] unless Payjp.api_key

        charge = Payjp::Charge.create(
          amount: final_payment_amount,
          card: @payjp_token,
          currency: 'jpy'
        )

        @purchase.update!(status: 'paid')
      else
        @purchase.update!(status: 'paid_by_points')
      end

      return Result.new(success?: true, data: { purchase: @purchase, purchase_item: @purchase_item, ship: @ship })
    end
  rescue Payjp::PayjpError => e
    Rails.logger.error "PayJP決済エラー: #{e.message} (購入ID: #{@purchase&.id}, ユーザーID: #{@user.id})"
    Result.new(success?: false, error_message: "決済処理中にエラーが発生しました: #{e.message}")
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "レコード保存エラー: #{e.message} (購入ID: #{@purchase&.id}, ユーザーID: #{@user.id})"
    Result.new(success?: false, error_message: "データの保存中にエラーが発生しました: #{e.message}")
  rescue StandardError => e
    Rails.logger.error "予期せぬエラー: #{e.message} (購入ID: #{@purchase&.id}, ユーザーID: #{@user.id})\n#{e.backtrace.join("\n")}"
    Result.new(success?: false, error_message: "処理中に予期せぬエラーが発生しました: #{e.message}")
  end
end

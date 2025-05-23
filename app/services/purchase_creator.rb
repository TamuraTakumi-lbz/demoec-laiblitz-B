class PurchaseCreator
  Result = Struct.new(:success?, :data, :error_message, keyword_init: true)
  attr_reader :purchase

  def initialize(user:, item:, ship_params:, payjp_token:, coupon_id:, point_deal: nil, used_points: 0)
    @user = user
    @item = item
    @ship_params = ship_params
    @payjp_token = payjp_token

    @coupon_id   = coupon_id
    @used_points = used_points.to_i
    @point_deal = point_deal

    @errors = []
  end

  def call
    return Result.new(success?: false, error_message: '購入金額が0以下です。') if @item.price <= 0
    return Result.new(success?: false, error_message: 'ポイントの使用が0以下です。') if @used_points < 0

    ActiveRecord::Base.transaction do
      # クーポンが使用されれば値引き金額を,使用されなければ0を返すサービスを呼び出し
      coupon_discounted_amount = 0
      if @coupon_id.present?
        coupon_service = CouponApplicationService.new(
          user: @user,
          item_price_before_discount: @item.price,
          coupon_id: @coupon_id
        ).call
        unless coupon_service.success?
          @errors << coupon_service.error_message
          raise ActiveRecord::Rollback
        end
        coupon_discounted_amount = coupon_service.data[:discount]
      end
      puts coupon_service if coupon_service.present?

      # 値引き金額定義
      final_payment_amount = @item.price - @used_points - coupon_discounted_amount

      @purchase = Purchase.new(
        user: @user,
        total_price: @item.price,
        used_points: @used_points,
        final_payment_amount: final_payment_amount,
        coupon_discount_amount: coupon_discounted_amount,
        status: 'pending_payment'
      )

      unless @purchase.save
        return Result.new(success?: false, error_message: @purchase.errors.full_messages,
                          data: { errors_object: @purchase.errors })
      end

      @purchase_item = PurchaseItem.new(
        item: @item,
        purchase: @purchase,
        quantity: 1,
        price_at_purchase: @item.price
      )
      unless @purchase_item.save
        return Result.new(success?: false, error_message: @purchase_item.errors.full_messages,
                          data: { errors_object: @purchase_item.errors })
      end
      @ship = Ship.new(@ship_params.merge(purchase: @purchase))

      unless @ship.save
        return Result.new(success?: false, error_message: @ship.errors.full_messages,
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

      # ポイント利用の記録
      @point_deal.update!(purchase: @purchase) if @used_points > 0 && @point_deal.present?

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

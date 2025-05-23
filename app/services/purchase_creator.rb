class PurchaseCreator
  attr_reader :purchase, :errors

  def initialize(user:, item:, ship_params:, payjp_token:, coupon_id:)
    @user = user
    @item = item
    @ship_params = ship_params
    @payjp_token = payjp_token
    @coupon_id   = coupon_id
    @errors = []
  end

  def call
    # 購入のトランザクション

    ActiveRecord::Base.transaction do

      #クーポンが使用されれば値引き金額を,使用されなければ0を返すサービスを呼び出し
      coupon_service = CouponApplicationService.new(
        user:                       @user,
        item_price_before_discount: @item.price,
        coupon_id:                  @coupon_id
      ).call
      unless coupon_service.success?
        @errors << coupon_service.error_message
        raise ActiveRecord::Rollback
      end

      #値引き金額定義
      discount_amount = coupon_service.data[:discount]

      # final_payment_amountは将来クーポンやポイントを利用した際に変更する
      @purchase = Purchase.new(user: @user, total_price: @item.price, coupon_discount_amount: discount_amount,
                               status: 'paid', final_payment_amount: @item.price)
      @purchase.save!

      @purchase_item = PurchaseItem.new(item: @item, purchase: @purchase, quantity: 1, price_at_purchase: @item.price)
      @purchase_item.save!

      @ship = Ship.new(@ship_params)
      @ship.purchase = @purchase
      @ship.save!


      true
    end
  rescue Payjp::PayjpError => e
    @errors << "決済処理に失敗しました: #{e.message}"
    false
  rescue ActiveRecord::RecordInvalid => e
    @errors.concat(e.record.errors.full_messages)
    false
  rescue StandardError => e
    @errors << '予期せぬエラーが発生しました。時間をおいてお試しください。'
    false
  end
end

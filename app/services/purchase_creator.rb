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
      # final_payment_amountは将来クーポンやポイントを利用した際に変更する
      @purchase = Purchase.new(user: @user, total_price: @item.price,
                               status: 'paid', final_payment_amount: @item.price)
      @purchase.save!

      @purchase_item = PurchaseItem.new(item: @item, purchase: @purchase, quantity: 1, price_at_purchase: @item.price)
      @purchase_item.save!

      @ship = Ship.new(@ship_params)
      @ship.purchase = @purchase
      @ship.save!

       # クーポン割引額の計算
      coupon_discount = 0
      if @coupon_id.present?
        coupon = Coupon.find_by(id: @coupon_id)
        unless coupon && coupon.applicable_to?(@item.price)
          @errors << 'このクーポンは利用できません'
          raise ActiveRecord::Rollback
        end
        coupon_discount = coupon.discount_amount
      end

      #割引後金額の計算
      final_payment_amount = @item.price - coupon_discount

      #used_at(クーポンの使用履歴)のセット
      if @coupon_id.present?
        uc = @user.user_coupons.find_by(coupon_id: @coupon_id)
        uc&.update!(used_at: Time.current)
      end

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

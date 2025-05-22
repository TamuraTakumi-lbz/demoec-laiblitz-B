class PurchaseCreator
  attr_reader :purchase, :errors

  def initialize(user:, item:, ship_params:, payjp_token:)
    @user = user
    @item = item
    @ship_params = ship_params
    @payjp_token = payjp_token
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

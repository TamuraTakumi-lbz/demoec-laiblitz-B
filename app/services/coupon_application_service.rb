class CouponApplicationService
  Result = Struct.new(:success?, :data, :error_message, keyword_init: true)

  def initialize(user:, item_price_before_discount:, coupon_id:)
    @user      = user
    @price     = item_price_before_discount
    @coupon_id = coupon_id
  end

  def call
    #クーポンが選択されないなら、割引0でsuccessを返す
    #冗長な処理の可能性あり
    if @coupon_id.blank?
      return Result.new(
        success?: true,
        data:     { discount: 0 }
      )
    end

    #クーポンIDが存在しない場合、falseとエラー文を送信
    coupon = Coupon.active.find_by(id: @coupon_id)
    unless coupon
      return Result.new(
        success?:     false,
        error_message: "クーポンが見つかりません。"
      )
    end

    #IDが@userの利用可能クーポンにない場合、falseとエラー文を送信
    unless @user.available_coupons.exists?(id: coupon.id)
      return Result.new(
        success?:     false,
        error_message: "このクーポンは使用できないか、既に利用済みです。"
      )
    end

    #商品価格がクーポン適用可能範囲外の場合、falseとエラー文を送信
    unless coupon.applicable_to?(@price)
      return Result.new(
        success?:     false,
        error_message: "このクーポンは#{coupon.minimum_order_price}円以上の注文にのみ適用できます。"
      )
    end

    #ユーザーと指定クーポンの組み合わせが未使用スコープに無い場合、falseとエラー文を送信
    #二個個目の条件と重複するのでいらないかも
    # unless @user.user_coupons.unused.find_by(coupon_id: @coupon_id)
    #   return Result.new(
    #     success?:     false,
    #     error_message: "有効なクーポンが見つかりません。"
    #   )
    # end

    #値引き額と商品価格のうち小さい方を採用。決済額－を防止。
    discount = [coupon.discount_amount, @price].min

    #未使用のUserCouponをロックして mark_used!。クーポンを使用済みにする。
    begin
      ActiveRecord::Base.transaction do
        user_coupon = @user.user_coupons
                      .unused
                      .lock
                      .find_by!(coupon_id: @coupon_id)
        user_coupon.mark_used!
      end
    rescue ActiveRecord::RecordNotFound => e
    # lock/find_by! が失敗したとき
      return Result.new(
        success?:      false, 
        error_message: "クーポン使用履歴の更新に失敗しました: #{e.message}"
      )
    end

    #各種条件をクリアした場合、successとdataの送信を行う。
    return Result.new(success?: true, data: { discount: discount })

  rescue StandardError => e
    Result.new(success?: false, error_message: "予期せぬエラーが発生しました: #{e.message}")
  end
end
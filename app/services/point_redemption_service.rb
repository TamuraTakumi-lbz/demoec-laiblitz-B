class PointRedemptionService
  Result = Struct.new(:success?, :data, :error_message, keyword_init: true)

  def initialize(user:, purchase:, redemption_amount:, type_key: '0002')
    @user = user
    @type_key = type_key
    @purchase = purchase
    @redemption_amount = redemption_amount.to_i
  end

  def call
    point_deal_type = PointDealType.find_by(type_key: @type_key)

    return Result.new(success?: false, error_message: "指定されたアクションキーのポイント取引種別が見つかりません: #{@type_key}") unless point_deal_type

    if point_deal_type.is_deposit?
      return Result.new(success?: false, error_message: "指定されたアクションキーはポイント利用タイプではありません: #{@type_key}")
    end

    Result.new(success?: false, error_message: '利用ポイント数が0以下です。') if @redemption_amount <= 0

    unless @user.total_available_points >= @redemption_amount
      return Result.new(success?: false, error_message: '利用ポイント数が残高を超えています。')
    end

    # ポイント利用のトランザクション
    ActiveRecord::Base.transaction do
      point_deal = PointDeal.create!(
        user: @user,
        title: "#{point_deal_type.description || 'ポイント利用'} (#{@purchase.id})",
        point_deal_type: point_deal_type,
        purchase: @purchase,
        dealed_at: Time.current
      )

      PointWithdrawal.create!(point_deal: point_deal, withdrawal_amount: @redemption_amount)

      @user.total_available_points -= @redemption_amount

      unless @user.save
        error_msg = "ユーザーのポイント残高更新に失敗しました: #{@user.errors.full_messages.join(', ')}"
        Rails.logger.error error_msg
        raise ActiveRecord::Rollback, error_msg
      end

      return Result.new(success?: true,
                        data: { redemption_points: @redemption_amount, new_balance: @user.total_available_points,
                                point_deal: point_deal })
    end
  rescue ActiveRecord::Rollback => e
    Rails.logger.error("ポイント利用処理がロールバックされました: #{e.message}")
    Result.new(success?: false, error_message: e.message)
  rescue ActiveRecord::RecordInvalid => e # create! や save! でバリデーションエラーが発生した場合
    Rails.logger.error "ポイント利用処理中にバリデーションエラーが発生しました: #{e.message}\n#{e.backtrace.join("\n")}"
    Result.new(success?: false, error_message: "入力内容に誤りがあります: #{e.message}")
  rescue StandardError => e
    Rails.logger.error "ポイント利用処理中に予期せぬエラーが発生しました: #{e.class.name} - #{e.message}\n#{e.backtrace.join("\n")}"
    Result.new(success?: false, error_message: 'ポイント利用処理中に予期せぬエラーが発生しました。')
  end
end

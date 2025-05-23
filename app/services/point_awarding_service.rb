class PointAwardingService
  Result = Struct.new(:success?, :data, :error_message, keyword_init: true)

  def initialize(user:, purchase:, type_key: '0001')
    @user = user
    @type_key = type_key
    @purchase = purchase
  end

  def call
    point_deal_type = PointDealType.find_by(type_key: @type_key)
    # return unless point_deal_type

    return Result.new(success?: false, error_message: "指定されたアクションキーのポイント取引種別が見つかりません: #{@type_key}") unless point_deal_type

    unless point_deal_type.is_deposit?
      return Result.new(success?: false,
                        error_message: "指定されたアクションキーはポイント付与タイプではありません: #{@type_key}")
    end

    base_award_point = (@purchase.final_payment_amount * 0.005).floor

    # 将来的にはランクに応じてポイント付与率を変更する
    award_point = base_award_point
    expires_at = Time.current + 90.days

    return Result.new(success?: false, error_message: '付与ポイント数が0以下です。') if award_point <= 0

    ActiveRecord::Base.transaction do
      point_deal = PointDeal.create!(
        user: @user,
        title: "#{point_deal_type.description || 'ポイント付与'} (#{@purchase.id})",
        point_deal_type: point_deal_type,
        purchase: @purchase,
        dealed_at: Time.current
      )
      PointDeposit.create!(point_deal: point_deal, deposit_amount: award_point,
                           expires_at: expires_at)

      @user.total_available_points += award_point

      unless @user.save
        error_msg = "ユーザーのポイント残高更新に失敗しました: #{@user.errors.full_messages.join(', ')}"
        Rails.logger.error error_msg
        raise ActiveRecord::Rollback, error_msg
      end

      return Result.new(success?: true,
                        data: { awarded_points: award_point, new_balance: @user.total_available_points,
                                point_deal: point_deal })
    end
  rescue ActiveRecord::Rollback => e
    Rails.logger.error("ポイント付与処理がロールバックされました: #{e.message}")
    Result.new(success?: false, error_message: e.message)
  rescue ActiveRecord::RecordInvalid => e # create! や save! でバリデーションエラーが発生した場合
    Rails.logger.error "ポイント付与処理中にバリデーションエラーが発生しました: #{e.message}\n#{e.backtrace.join("\n")}"
    Result.new(success?: false, error_message: "入力内容に誤りがあります: #{e.message}")
  rescue StandardError => e
    Rails.logger.error "ポイント付与処理中に予期せぬエラーが発生しました: #{e.class.name} - #{e.message}\n#{e.backtrace.join("\n")}"
    Result.new(success?: false, error_message: 'ポイント付与処理中に予期せぬエラーが発生しました。')
  end
end

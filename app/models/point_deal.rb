class PointDeal < ApplicationRecord
  belongs_to :user
  belongs_to :point_deal_type
  belongs_to :purchase, optional: true
  belongs_to :reverting_point_deal, class_name: 'PointDeal', optional: true

  has_one :point_deposit, dependent: :destroy
  has_one :point_withdrawal, dependent: :destroy

  # validate :deposit_or_withdrawal_must_exist_based_on_type

  validates :title, presence: true

  private

  # def deposit_or_withdrawal_must_exist_based_on_type
  #   # point_deal_type がないと判定できない
  #   return unless point_deal_type

  #   if point_deal_type.is_deposit # ポイント付与タイプの場合
  #     errors.add(:base, 'ポイント付与タイプの取引にはポイント付与詳細が必要です。') if point_deposit.nil?
  #     errors.add(:base, 'ポイント付与タイプの取引にポイント利用/失効詳細があってはいけません。') if point_withdrawal.present?
  #   else # ポイント付与タイプ以外（利用/失効など）の場合
  #     errors.add(:base, 'ポイント利用/失効タイプの取引にはポイント利用/失効詳細が必要です。') if point_withdrawal.nil?
  #     errors.add(:base, 'ポイント利用/失効タイプの取引にポイント付与詳細があってはいけません。') if point_deposit.present?
  #   end
  # end
end

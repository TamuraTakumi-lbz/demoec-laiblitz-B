class UserCoupon < ApplicationRecord
  belongs_to :user
  belongs_to :coupon
  #同一のcoupon_idに対してのみ、ユニーク制約を設定。
  validates :user_id, uniqueness: { scope: :coupon_id, message: 'はこのクーポンを既に付与されています' }

  # 使用済み判定
  def used?
    used_at.present?
  end
end

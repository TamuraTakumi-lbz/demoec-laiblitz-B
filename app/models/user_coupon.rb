class UserCoupon < ApplicationRecord
  belongs_to :user
  belongs_to :coupon
  #同一のcoupon_idに対してのみ、ユニーク制約を設定。
  validates :user_id, uniqueness: { scope: :coupon_id, message: 'はこのクーポンを既に付与されています' }

  #使用済みのレコードをクエリで回収
  scope :used, ->{
    where.not(used_at: nil)
  }
  #未使用のレコードをクエリで回収
  scope :unused, ->{
    where(used_at: nil)
  }

  #トランザクション内で使用想定
  def mark_used!
    update!(used_at: Time.current)
  end

  # 使用済み判定
  def used?
    used_at.present?
  end
end

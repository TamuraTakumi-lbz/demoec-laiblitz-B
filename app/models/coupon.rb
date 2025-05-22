class Coupon < ApplicationRecord
  has_many :user_coupons, dependent: :destroy
  has_many :users, through: :user_coupons

  validates :name,            presence: true,length: { maximum: 50, message: "は50文字以内で入力してください" } #文字数の制約：DBレベルでは未実装
  validates :description,     presence: true, length: { maximum: 500, message: "は500文字以内で入力してください" } #文字数の制約：DBレベルでは未実装
  validates :discount_amount, presence: true, numericality: { only_integer: true, greater_than: 0 } #整数かつ0より大きい
  validates :minimum_order_price, numericality: { only_integer: true, greater_than_or_equal_to: 0 } #整数かつ0以上
  validates :expires_on,      presence: true
  validates :is_active,       inclusion: { in: [true, false] } #falseがnil判定されるのを防止
  validate :expires_on_cannot_be_in_past
  before_validation :ensure_defaults

  #有効期限かつ有効フラグがtrueのクーポンをクエリで回収
  scope :active, ->{
    where(is_active: true).where("expires_on >=?", Date.current)
  }

  #有効期限かつ有効フラグがtrueかを判定
  def active?
    is_active && expires_on >= Date.current
  end

  #値引き金額(クーポンが適用可能な最低価格)がorder_price以下かを判定(整数返還いらないかも)
  def applicable_to?(order_price)
    active? && minimum_order_price.to_i <= order_price.to_i
  end

  #割引処理
  def apply_discount(order_price)
    base = order_price.to_i
    [base - discount_amount, 0].max
  end

  #createアクション実行後に、クーポン配布
  after_create :distribute_to_common_users

  private
  #デフォ値再設定←いらないかも
  def ensure_defaults
    self.minimum_order_price ||= 0
    self.is_active = true if is_active.nil?
  end

  #すでに期限切れのクーポンを作成することを防止
  def expires_on_cannot_be_in_past
    return if expires_on.blank? || expires_on >= Date.current
    errors.add(:expires_on, "は今日以降の日付を指定してください")
  end

  #中間テーブルにeach文でレコードを追加していくことで、adminでないユーザー全員にクーポンを配布
  def distribute_to_common_users
    User.where(is_admin: false).find_each(batch_size: 1000) do |user|
      user.user_coupons.create!(coupon: self)
    end
  end

end

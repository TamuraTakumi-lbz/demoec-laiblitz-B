class User < ApplicationRecord
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  validates :nickname, presence: true, uniqueness: true
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :last_name_kanji, :first_name_kanji, presence: true
  validates :last_name_kanji, :first_name_kanji,
            format: { with: /\A[ぁ-んァ-ヶ一-龥々ー]+\z/ }
  validates :last_name_kana, :first_name_kana, presence: true
  validates :last_name_kana, :first_name_kana,
            format: { with: /\A[ァ-ヶー]+\z/ }

  # その他
  validates :birth_date, presence: true

  # パスワードの英数字混合ルールを追加（Deviseのvalidationsを拡張）
  validate :password_complexity

  has_many :purchases, dependent: :destroy

  #Couponモデル・UserCouponモデルとの関連付け
  has_many :user_coupons, dependent: :destroy
  has_many :coupons,      through:   :user_coupons

  #有効かつ、該当userが未使用のクーポン取得。current.user.available_couponsで想定
  def available_coupons
    self.coupons.active.merge(user_coupons.unused).distinct
  end

  after_create :assign_all_active_coupons
  belongs_to :user_rank, optional: true
  has_many :point_deals, dependent: :destroy

  has_many :point_deposits, through: :point_deals
  has_many :point_withdrawals, through: :point_dealss

  private

  def password_complexity
    return if password.blank? || password =~ /\A(?=.*?[a-zA-Z])(?=.*?\d)[a-zA-Z\d]+\z/

    errors.add(:password, :password_complexity)
  end

  #ユーザー登録時に有効かつ期限内のクーポンを全て配布
  def assign_all_active_coupons
    Coupon.where(is_active: true).where("expires_on >= ?", Date.current)
      .find_each(batch_size: 1000) do |coupon|
        user_coupons.create!(coupon: coupon)
      end
  end
end

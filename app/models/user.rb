class User < ApplicationRecord
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :nickname, presence: true, uniqueness: true

  validates :last_name_kanji, :first_name_kanji, presence: true
  validates :last_name_kanji, :first_name_kanji,
            format: { with: /\A[ぁ-んァ-ヶ一-龥々ー]+\z/, message: 'は全角（漢字・ひらがな・カタカナ）で入力してください' }
  validates :last_name_kana, :first_name_kana, presence: true
  validates :last_name_kana, :first_name_kana,
            format: { with: /\A[ァ-ヶー]+\z/, message: 'は全角カタカナで入力してください' }

  # その他
  validates :birth_date, presence: true

  # パスワードの英数字混合ルールを追加（Deviseのvalidationsを拡張）
  validate :password_complexity

  has_many :purchases, dependent: :destroy

  private

  def password_complexity
    return if password.blank? || password =~ /\A(?=.*?[a-zA-Z])(?=.*?\d)[a-zA-Z\d]+\z/

    errors.add(:password, 'は半角英字と数字の両方を含めてください')
  end

end

class User < ApplicationRecord
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :nickname, presence: true, uniqueness: true

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


  private

  def password_complexity
    return if password.blank? || password =~ /\A(?=.*?[a-zA-Z])(?=.*?\d)[a-zA-Z\d]+\z/

    errors.add(:password, :password_complexity)
  end

end

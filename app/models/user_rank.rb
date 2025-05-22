class UserRank < ApplicationRecord
  has_many :users

  validates :rank_name, presence: true, uniqueness: true
  validates :description, presence: true

  # ランキ機能実装後に利用する
  # validates :point_award_rate, presence: true,
  #                              numericality: { greater_than: 0 }
end

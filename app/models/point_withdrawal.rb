class PointWithdrawal < ApplicationRecord
  belongs_to :point_deal

  validates :withdrawal_amount, presence: true,
                                numericality: { greater_than: 0 }
end

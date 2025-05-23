class PointDeposit < ApplicationRecord
  belongs_to :point_deal

  validates :deposit_amount, presence: true,
                             numericality: { greater_than: 0 }
end

class PointDealType < ApplicationRecord
  has_many :point_deals, dependent: :restrict_with_error

  validates :type_key, presence: true, uniqueness: true
  validates :is_deposit, inclusion: { in: [true, false] }
  validates :description, presence: true
end

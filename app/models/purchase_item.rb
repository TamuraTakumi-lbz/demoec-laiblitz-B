class PurchaseItem < ApplicationRecord
  belongs_to :item
  belongs_to :purchase

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price_at_purchase, presence: true,
                                numericality: { greater_than: 0 }
end

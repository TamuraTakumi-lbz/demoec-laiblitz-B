class Purchase < ApplicationRecord
  has_many :purchase_items, dependent: :destroy
  belongs_to :user
  has_one :ship, dependent: :destroy
end

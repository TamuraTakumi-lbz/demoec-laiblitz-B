class Purchase < ApplicationRecord

  attr_accessor :token

  belongs_to :item
  belongs_to :user
  has_one :ship, dependent: :destroy

end

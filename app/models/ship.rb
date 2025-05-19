class Ship < ApplicationRecord
  
  validates :postal_code, presence: true, format: { with: /\A[0-9]{3}-[0-9]{4}\z/,
                                                    message: 'is invalid. Include hyphen(-)', maximum: 8 }

  validates :prefecture_id, numericality: { other_than: 1, message: "can't be blank" }
  validates :city, presence: true
  validates :street_address, presence: true
  validates :phone_number, presence: true,
                           format: { with: /\A[0-9]{10,11}\z/, message: 'is invalid. Input half-width characters' }

  belongs_to :purchase
end

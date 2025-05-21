class Item < ApplicationRecord
  validates :name, presence: { message: "can't be blank" }
  validates :description, presence: { message: "can't be blank" }
  validates :price, presence: { message: "can't be blank" }
  validates :image, presence: { message: "can't be blank" }

  validate :half_width_digits_only_for_price
  validates :price, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 300,
    less_than_or_equal_to: 9_999_999,
    message: 'is out of setting range'
  }

  has_many :purchases, through: :purchase_items

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :category
  belongs_to :condition

  validates :category_id, numericality: { other_than: 1, message: "can't be blank" }
  validates :condition_id, numericality: { other_than: 1, message: "can't be blank" }

  has_one_attached :image

  private

  def half_width_digits_only_for_price
    raw = price_before_type_cast
    return unless raw.present? && raw !~ /\A[0-9]+\z/

    errors.add(:price, 'is invalid. Input half-width characters')
  end
end

class Item < ApplicationRecord
  validates :name, presence: {message: "can't be blank"}
  validates :description, presence: {message: "can't be blank"}
  validates :price, presence: {message: "can't be blank"}
  validates :image, presence: {message: "can't be blank"}

  validates :price, format: { with: /\A[0-9]+\z/ , message: 'is invalid. Input half-width characters'}
  validates :price, numericality: { greater_than: 300, less_than: 9999999, message: "is out of setting range"}

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :category
  belongs_to :condition

  validates :category_id, numericality: { other_than: 1, message: "can't be blank" } 
  validates :condition_id, numericality: { other_than: 1, message: "can't be blank" } 

  has_one_attached :image

end

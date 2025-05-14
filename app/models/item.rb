class Item < ApplicationRecord
  validates :name, presence: true
  validates :image, presence: true
  validates :description, presence: true
  validates :price, presence: true

  validates :price, numericality: { greater_than: 300, less_than: 9999999}, format: { with: /\A[0-9]+\z/ }


  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :category
  belongs_to :condition

  validates :category_id, numericality: { other_than: 1, message: "can't be blank" } 
  validates :condition_id, numericality: { other_than: 1, message: "can't be blank" } 

  has_one_attached :image

end

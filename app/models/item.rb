class Item < ApplicationRecord
  has_many :categories
  has_many :conditions
end

class Item < ApplicationRecord
  belongs_to :condition
  belongs_to :category
end

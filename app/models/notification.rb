class Notification < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true
  validates :starts_at, presence: true
  validates :starts_at, comparison: {greater_than: Time.now}
  validates :ends_at, comparison: {greater_than: :starts_at}, allow_nil: true
  
end

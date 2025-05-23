class Promotion < ApplicationRecord
  validates :promotion_image, presence: true
  validates :title, presence: true
  validates :content, presence: true
  validate :starts_at_must_be_present_and_in_the_future
  validates :ends_at, comparison: {greater_than: :starts_at}, allow_nil: true
  validates :url, presence: true
  

  has_one_attached :promotion_image

  private
  def starts_at_must_be_present_and_in_the_future
    if starts_at.blank?
      errors.add(:starts_at, :blank) 
      return
    end

    if starts_at <= Time.now
      errors.add(:starts_at, :current_time) # value を渡してエラーメッセージに含めることも可能
    end
  end
end

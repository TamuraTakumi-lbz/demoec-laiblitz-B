class Condition < ActiveHash::Base
  self.data = [
    { id: 1, condition_name: '---' },
    { id: 2, condition_name: '新品・未使用' },
    { id: 3, condition_name: '未使用に近い' },
    { id: 4, condition_name: '目立った傷や汚れなし' },
    { id: 5, condition_name: 'やや傷や汚れあり' },
    { id: 6, condition_name: '傷や汚れあり' },
    { id: 7, condition_name: '全体的に状態が悪い' }
  ]

  include ActiveHash::Associations
  has_many :items

  def self.ransackable_attributes(auth_object = nil)
    %w[condition_name]
  end
end

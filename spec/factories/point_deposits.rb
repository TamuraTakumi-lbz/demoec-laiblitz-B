FactoryBot.define do
  factory :point_deposit do
    association :point_deal
    deposit_amount { 100 }
  end
end

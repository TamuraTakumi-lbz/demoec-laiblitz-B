FactoryBot.define do
  factory :point_withdrawal do
    association :point_deal
    withdrawal_amount { 50 }
  end
end

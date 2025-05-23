FactoryBot.define do
  factory :point_deal_type do
    sequence(:type_key) { |n| "test_type_#{n}" }
    description { 'Test Deal Type' }
    is_deposit { true } # または false
  end
end

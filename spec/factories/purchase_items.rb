FactoryBot.define do
  factory :purchase_item do
    item { nil }
    purchase { nil }
    quantity { 1 }
    price_at_purchase { 1 }
  end
end

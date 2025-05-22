FactoryBot.define do
  factory :point_deal do
    association :user
    association :point_deal_type
    title { 'Test Point Deal' }
    dealed_at { Time.current }
  end

  trait :deposit do
    association :point_deal_type, factory: :point_deal_type, is_deposit: true # is_deposit: true を明示
    after(:create) do |deal| # create の後に PointDeposit を作成
      create(:point_deposit, point_deal: deal)
    end
  end

  trait :withdrawal do
    association :point_deal_type, factory: :point_deal_type, is_deposit: false # is_deposit: false を明示
    after(:create) do |deal| # create の後に PointWithdrawal を作成
      create(:point_withdrawal, point_deal: deal)
    end
  end
end

FactoryBot.define do
  factory :user_rank do
    sequence(:rank_name) { |n| "Rank #{n}" }
    description { 'This is a test rank.' }
    # point_award_rate は将来実装なのでコメントアウト
  end
end

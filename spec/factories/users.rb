FactoryBot.define do
  factory :user do
    nickname { Faker::Name.unique.name }
    email { Faker::Internet.unique.email }
    password { 'password123' } # Deviseの要件に合わせる
    password_confirmation { 'password123' }
    last_name_kanji { '山田' }
    first_name_kanji { '太郎' }
    last_name_kana { 'ヤマダ' }
    first_name_kana { 'タロウ' }
    birth_date { Faker::Date.birthday(min_age: 18, max_age: 65) }
    is_admin { false }
    total_available_points { 0 }
    lock_version { 0 }
  end
end

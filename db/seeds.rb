# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

# 管理者ユーザーが存在しない場合のみ作成
# email をユニークなキーとして利用
admin_email = 'admin@example.com'

unless User.exists?(email: admin_email)
  User.create!(
    email: admin_email,
    password: 'password123',
    password_confirmation: 'password123', 
    is_admin: true,
    nickname: '管理者',
    last_name_kanji: '管理',
    first_name_kanji: '者',
    last_name_kana: 'カンリ',
    first_name_kana: 'シャ',
    birth_date: '1980-04-01' 
  )
  puts "Admin user with email '#{admin_email}' created."
else
  puts "Admin user with email '#{admin_email}' already exists."
end

common_email = 'common@example.com'

unless User.exists?(email: common_email)
  User.create!(
    email: common_email,
    password: 'password123',
    password_confirmation: 'password123', 
    is_admin: false,
    nickname: '一般人',
    last_name_kanji: '一般',
    first_name_kanji: '人',
    last_name_kana: 'イッパン',
    first_name_kana: 'ジン',
    birth_date: '1980-04-02' 
  )
  puts "Common user with email '#{common_email}' created."
else
  puts "Common user with email '#{common_email}' already exists."
end


Item.create!(
  name: 'Sample Item 1',
  description: 'これは最初のサンプルアイテムです。',
  price: 1000,
  category_id: 2,
  condition_id: 2,
  # image: ActiveStorage::Blob.create_and_upload!(
  #   io: File.open(Rails.root.join('app/assets/images/item-sample.png')), # 適切な画像ファイルパスに変更
  #   filename: 'item-sample.png',
  #   content_type: 'image/png'
  # )
)
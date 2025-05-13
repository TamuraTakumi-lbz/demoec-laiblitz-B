
class Category < ActiveHash::Base
  self.data = [
    {id: 1, category_name: '---'},
    {id: 2, category_name: 'メンズ'},
    {id: 3, category_name: 'レディース'},
    {id: 4, category_name: 'ベビー・キッズ'},
    {id: 5, category_name: 'インテリア・住まい・小物'},
    {id: 6, category_name: '本・音楽・ゲーム'},
    {id: 7, category_name: 'おもちゃ・ホビー・グッズ'},
    {id: 8, category_name: '家電・スマホ・カメラ'},
    {id: 9, category_name: 'スポーツ・レジャー'},
    {id: 10, category_name: 'ハンドメイド'},
    {id: 11, category_name: 'その他'}
  ]

  include ActiveHash::Associations
  has_many :items


end

# DemoEC - Eコマースデモアプリケーション

商品リスト、ユーザーアカウント、ショッピングカート機能、注文処理を備えた総合的なEコマースプラットフォームです。

## システム設計

![ER図](./ER_diagram.png)

## 機能

- ユーザー認証とプロフィール管理
- カテゴリーと検索機能を備えた商品カタログ
- ショッピングカートと決済プロセス
- 注文履歴と追跡
- 在庫管理用の管理者ダッシュボード

## はじめ方

### 前提条件
- `.ruby-version`で指定されているRubyバージョン
- Railsフレームワーク
- 設定されているデータベースシステム

### インストール
1. このリポジトリをクローンする
2. `bundle install`を実行する
3. `rails db:create db:migrate`でデータベースをセットアップする
4. `rails server`でサーバーを起動する



## ER図（テーブル定義とアソシエーション）

### Userテーブル (users)

|   |   |   |
|---|---|---|
|Column|Type|Options|
|id|bigint|null: false, primary_key: true|
|nickname|string|null: false|
|email|string|null: false, unique: true|
|password_digest|string|null: false|
|last_name_kanji|string|null: false|
|first_name_kanji|string|null: false|
|last_name_kana|string|null: false|
|first_name_kana|string|null: false|
|birth_date|date|null: false|
|is_admin|boolean|null: false, default: false|
|created_at|datetime|null: false|
|updated_at|datetime|null: false|

#### Association
- has_many :items, foreign_key: "user_id"
- has_many :purchases, foreign_key: "user_id"
---

### Itemテーブル (items)

|   |   |   |
|---|---|---|
|Column|Type|Options|
|id|bigint|null: false, primary_key: true|
|name|string|null: false|
|description|text|null: false|
|price|integer|null: false|
|user|references|null: false, foreign_key: true|
|category|references|null: false, foreign_key: true|
|condition|references|null: false, foreign_key: true|
|has_bought|boolean|null: false, default: false|
|created_at|datetime|null: false|
|updated_at|datetime|null: false|

#### Association

- belongs_to :user
- belongs_to :category
- belongs_to :condition
- has_many :purchases (または、在庫管理の概念により has_one :purchase の場合もある)
    

---

### Categoryテーブル (categories)

|   |   |   |
|---|---|---|
|Column|Type|Options|
|id|bigint|null: false, primary_key: true|
|name|string|null: false, unique: true|
|created_at|datetime|null: false|
|updated_at|datetime|null: false|

#### Association

- has_many :items
    

---

### Conditionテーブル (conditions)

|   |   |   |
|---|---|---|
|Column|Type|Options|
|id|bigint|null: false, primary_key: true|
|name|string|null: false, unique: true|
|created_at|datetime|null: false|
|updated_at|datetime|null: false|

#### Association

- has_many :items
---

### Purchaseテーブル (purchases)
|   |   |   |
|---|---|---|
|Column|Type|Options|
|id|bigint|null: false, primary_key: true|
|user|references|null: false, foreign_key: true|
|item|references|null: false, foreign_key: true|
|price_at_purchase|integer|null: false|
|purchased_at|datetime|null: false|
|created_at|datetime|null: false|
|updated_at|datetime|null: false|

#### Association

- belongs_to :user
- belongs_to :item
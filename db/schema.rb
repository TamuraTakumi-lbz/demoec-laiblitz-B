# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_05_21_052936) do
  create_table "active_storage_attachments", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb3", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "items", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id", null: false
    t.bigint "condition_id", null: false
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["condition_id"], name: "index_items_on_condition_id"
  end

  create_table "point_deal_types", charset: "utf8mb3", force: :cascade do |t|
    t.string "type_key", null: false
    t.string "description", null: false
    t.boolean "is_deposit", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "point_deals", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.bigint "point_deal_type_id", null: false
    t.bigint "purchase_id"
    t.bigint "reverting_point_deal_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["point_deal_type_id"], name: "index_point_deals_on_point_deal_type_id"
    t.index ["purchase_id"], name: "index_point_deals_on_purchase_id"
    t.index ["reverting_point_deal_id"], name: "index_point_deals_on_reverting_point_deal_id"
    t.index ["user_id"], name: "index_point_deals_on_user_id"
  end

  create_table "point_deposits", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "point_deal_id", null: false
    t.integer "deposit_amount", null: false
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["point_deal_id"], name: "index_point_deposits_on_point_deal_id"
    t.index ["user_id"], name: "index_point_deposits_on_user_id"
  end

  create_table "point_with_drawals", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "point_deal_id", null: false
    t.integer "withdrawal_amount", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["point_deal_id"], name: "index_point_with_drawals_on_point_deal_id"
    t.index ["user_id"], name: "index_point_with_drawals_on_user_id"
  end

  create_table "purchase_items", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "purchase_id", null: false
    t.integer "quantity"
    t.integer "price_at_purchase"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_purchase_items_on_item_id"
    t.index ["purchase_id"], name: "index_purchase_items_on_purchase_id"
  end

  create_table "purchases", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_price", default: 0, null: false
    t.integer "used_points", default: 0, null: false
    t.integer "coupon_discount_amount", default: 0, null: false
    t.integer "final_payment_amount", default: 0, null: false
    t.string "payment_method"
    t.string "status", default: "pending_payment", null: false
    t.index ["user_id"], name: "index_purchases_on_user_id"
  end

  create_table "ships", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "purchase_id", null: false
    t.string "postal_code"
    t.integer "prefecture_id"
    t.string "city"
    t.string "street_address"
    t.string "building_name"
    t.string "phone_number"
    t.index ["purchase_id"], name: "index_ships_on_purchase_id"
  end

  create_table "user_ranks", charset: "utf8mb3", force: :cascade do |t|
    t.string "rank_name", null: false
    t.text "description", null: false
    t.float "point_award_rate", default: 1.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb3", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.boolean "is_admin", default: false, null: false
    t.string "nickname", null: false
    t.string "last_name_kanji"
    t.string "first_name_kanji"
    t.string "last_name_kana"
    t.string "first_name_kana"
    t.date "birth_date"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_rank_id"
    t.integer "total_available_points", default: 0, null: false
    t.integer "lock_version", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["user_rank_id"], name: "index_users_on_user_rank_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "point_deals", "point_deal_types"
  add_foreign_key "point_deals", "point_deals", column: "reverting_point_deal_id"
  add_foreign_key "point_deals", "purchases"
  add_foreign_key "point_deals", "users"
  add_foreign_key "point_deposits", "point_deals"
  add_foreign_key "point_deposits", "users"
  add_foreign_key "point_with_drawals", "point_deals"
  add_foreign_key "point_with_drawals", "users"
  add_foreign_key "purchase_items", "items"
  add_foreign_key "purchase_items", "purchases"
  add_foreign_key "purchases", "users"
  add_foreign_key "users", "user_ranks"
end

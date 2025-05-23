class CreateUserCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :user_coupons do |t|
      t.references :user,   null: false, foreign_key: true
      t.references :coupon, null: false, foreign_key: true
      t.datetime   :used_at
      t.timestamps
    end
    #同一ユーザーの同一クーポン利用を防止
    add_index :user_coupons, [:user_id, :coupon_id], unique: true
  end
end

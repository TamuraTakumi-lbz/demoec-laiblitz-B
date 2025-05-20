class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string  :name,                 null: false
      t.text    :description,          null: false
      t.integer :discount_amount,      null: false
      t.integer :minimum_order_price,  default: 0
      t.date    :expires_on,           null: false
      t.boolean :is_active,            null: false, default: true
      t.timestamps
    end

    add_index :coupons, :name
    add_index :coupons, :expires_on
    add_index :coupons, :is_active
  end
end
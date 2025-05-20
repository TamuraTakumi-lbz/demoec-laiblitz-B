class CreatePurchaseItems < ActiveRecord::Migration[7.1]
  def change
    create_table :purchase_items do |t|
      t.references :item, null: false, foreign_key: true
      t.references :purchase, null: false, foreign_key: true
      t.integer :quantity
      t.integer :price_at_purchase

      t.timestamps
    end
  end
end

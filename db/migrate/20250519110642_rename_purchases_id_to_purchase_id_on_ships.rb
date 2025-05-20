class RenamePurchasesIdToPurchaseIdOnShips < ActiveRecord::Migration[7.1]
  def change
    if foreign_key_exists?(:ships, column: :purchases_id)
      remove_foreign_key :ships, column: :purchases_id
    end

    if index_exists?(:ships, :purchases_id, name: "index_ships_on_purchases_id")
      remove_index :ships, name: "index_ships_on_purchases_id"
    end

    rename_column :ships, :purchases_id, :purchase_id

    add_index :ships, :purchase_id

    add_foreign_key :ships, :purchases, column: :purchase_id
  end
end

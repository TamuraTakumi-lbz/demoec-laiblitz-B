class RenamePurchaseIdToPurchasesIdInShips < ActiveRecord::Migration[7.1]
  def change
    rename_column :ships, :purchase_id, :purchases_id
  end
end

class AddConstraintsToPurchaseItems < ActiveRecord::Migration[7.1]
  def change
    change_column_null :purchase_items, :price_at_purchase, false

    change_column_null :purchase_items, :quantity, false
    change_column_default :purchase_items, :quantity, 1

  end
end
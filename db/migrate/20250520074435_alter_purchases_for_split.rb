class AlterPurchasesForSplit < ActiveRecord::Migration[7.1]
  def change
        remove_reference :purchases, :item, null: false, foreign_key: true

        add_column :purchases, :total_price, :integer, null: false, default: 0
        add_column :purchases, :used_points, :integer, null: false, default: 0
        add_column :purchases, :coupon_discount_amount, :integer, null: false, default: 0
        add_column :purchases, :final_payment_amount, :integer, null: false, default: 0
        add_column :purchases, :payment_method, :string
        add_column :purchases, :status, :string, null: false, default: 'pending_payment' 
  end
end

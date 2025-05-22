class AddDealedAtColumnToPointDeal < ActiveRecord::Migration[7.1]
  def change
    add_column :point_deals, :dealed_at, :datetime, null: false
    add_index :point_deals, :dealed_at
  end
end

class CreatePointDeposits < ActiveRecord::Migration[7.1]
  def change
    create_table :point_deposits do |t|
      t.references :user, null: false, foreign_key: true
      t.references :point_deal, null: false, foreign_key: true
      t.integer "deposit_amount", null: false
      t.datetime "expires_at"

      t.timestamps
    end

  end
end

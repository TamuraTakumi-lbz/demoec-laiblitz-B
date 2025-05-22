class CreatePointWithdrawal < ActiveRecord::Migration[7.1]
  def change
    create_table :point_withdrawals do |t|
      t.references :point_deal, null: false, foreign_key: true, 
                            index: { unique: true }
      t.integer "withdrawal_amount", null: false


      t.timestamps
    end
  end
end

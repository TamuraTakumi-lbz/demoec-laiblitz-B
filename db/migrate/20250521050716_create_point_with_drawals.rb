class CreatePointWithDrawals < ActiveRecord::Migration[7.1]
  def change
    create_table :point_with_drawals do |t|
      t.references :user, null: false, foreign_key: true
      t.references :point_deal, null: false, foreign_key: true
      t.integer "withdrawal_amount", null: false

      t.timestamps
    end

  end
end

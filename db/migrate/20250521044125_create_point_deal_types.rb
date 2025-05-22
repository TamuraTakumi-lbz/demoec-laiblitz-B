class CreatePointDealTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :point_deal_types do |t|
      t.string "type_key", null: false
      t.string "description", null: false
      t.boolean "is_deposit", default: true, null: false

      t.timestamps
    end

  end
end

class CreatePointDeals < ActiveRecord::Migration[7.1]
  def change
    create_table :point_deals do |t|
      t.references :user, null: false, foreign_key: true
      t.string "title",  null: false


      t.references :point_deal_type, null: false, foreign_key: true
      t.references :purchase, foreign_key: true, null: true
      t.references :reverting_point_deal, 
                      foreign_key: { to_table: :point_deals }, null: true
      t.text "description"

      t.timestamps
    end
  end
end

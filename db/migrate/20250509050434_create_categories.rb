class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.references :purchase, null: false, foreign_key: true, unique: true
      t.string :postal_code,    null: false                                 
      t.integer :prefecture_id, null: false                                 
      t.string :city,           null: false                                 
      t.string :street_address, null: false
      t.string :building_name
      t.string :phone_number,   null: false                                
      t.timestamps
    end
  end
end

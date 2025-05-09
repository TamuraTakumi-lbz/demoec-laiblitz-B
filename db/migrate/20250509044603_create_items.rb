class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.string :name
      t.text :description
      t.text :condition
      t.integer :price
      t.boolean :has_bought
      
      t.timestamps
    end
  end
end

class CreateConditions < ActiveRecord::Migration[7.1]
  def change
    create_table :conditions do |t|
      t.text :condition
      t.timestamps
    end
  end
end

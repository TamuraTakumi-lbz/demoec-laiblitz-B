class DropCategorisandConditions < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :items, :categories
    remove_foreign_key :items, :conditions

    drop_table :categories
    drop_table :conditions
  end
end

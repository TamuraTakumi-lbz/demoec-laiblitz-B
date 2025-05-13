class ChangeItemsNull < ActiveRecord::Migration[7.1]
  def change
    change_column_null :items, :category_id, false
    change_column_null :items, :condition_id, false
  end
end

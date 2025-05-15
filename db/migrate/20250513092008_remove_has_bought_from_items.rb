class RemoveHasBoughtFromItems < ActiveRecord::Migration[7.1]
  def change
    remove_column :items, :has_bought, :boolean
  end
end

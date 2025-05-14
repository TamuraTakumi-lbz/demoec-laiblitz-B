class AddColumnsToShips < ActiveRecord::Migration[7.1]
  def change
    add_reference :ships, :purchases, null: false, foreign_key: true
    add_column :ships, :postal_code, :string
    add_column :ships, :prefecture_id, :integer
    add_column :ships, :city, :string
    add_column :ships, :street_address, :string
    add_column :ships, :building_name, :string
    add_column :ships, :phone_number, :string
  end
end

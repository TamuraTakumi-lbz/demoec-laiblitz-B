class CreatePromotions < ActiveRecord::Migration[7.1]
  def change
    create_table :promotions do |t|
      t.string :title
      t.text :content
      t.datetime :starts_at
      t.datetime :ends_at, null: true
      t.boolean :is_published, default: false
      t.string :url
      t.timestamps
    end
  end
end

class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.string :title
      t.text :content
      t.datetime :starts_at
      t.datetime :ends_at, null: true
      t.boolean :is_published, default: false
      t.timestamps
    end
  end
end

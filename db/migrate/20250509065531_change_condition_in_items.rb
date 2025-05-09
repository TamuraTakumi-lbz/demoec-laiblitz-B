class ChangeConditionInItems < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:items, :condition)
      remove_column :items, :condition, :text
    end

    # items テーブルに condition_id を追加し、conditions テーブルへの外部キー制約とインデックスを設定
    add_reference :items, :condition, foreign_key: true, index: true
  end
end

class AddColumntToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :user_rank, foreign_key: true, null: true

    # 現在利用可能なポイント総量 (非正規化カラム)
    add_column :users, :total_available_points, :integer, default: 0, null: false

    # 楽観的ロック用バージョン
    add_column :users, :lock_version, :integer, default: 0, null: false
  end
end
